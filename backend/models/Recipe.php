<?php
class Recipe {
    private $conn;
    private $table_name = "recipes";

    public function __construct($db) {
        $this->conn = $db;
    }

    private function attachDetails($recipes) {
        if (empty($recipes)) return [];

        foreach ($recipes as &$recipe) {
            // Force keys to lowercase to avoid ID vs id issues
            $recipe = array_change_key_case($recipe, CASE_LOWER);
            $recipeId = $recipe['id'] ?? null;

            if (!$recipeId) continue;

            // Fetch ingredients
            $query = "SELECT i.name, ri.amount FROM ingredients i 
                      JOIN recipe_ingredients ri ON i.id = ri.ingredient_id 
                      WHERE ri.recipe_id = ?";
            $stmt = $this->conn->prepare($query);
            $stmt->execute([$recipeId]);
            $ingredients = $stmt->fetchAll(PDO::FETCH_ASSOC);
            
            // Force ingredient keys to lowercase
            $recipe['ingredients'] = array_map(function($i) {
                return array_change_key_case($i, CASE_LOWER);
            }, $ingredients);

            // Fetch steps
            $query = "SELECT description FROM cooking_steps WHERE recipe_id = ? ORDER BY step_number ASC";
            $stmt = $this->conn->prepare($query);
            $stmt->execute([$recipeId]);
            $recipe['steps'] = $stmt->fetchAll(PDO::FETCH_COLUMN);
        }
        unset($recipe); // Break the reference
        return $recipes;
    }

    public function getById($id) {
        $query = "SELECT * FROM " . $this->table_name . " WHERE id = ?";
        $stmt = $this->conn->prepare($query);
        $stmt->execute([$id]);
        $recipe = $stmt->fetch(PDO::FETCH_ASSOC);
        if (!$recipe) return null;
        
        $recipes = [$recipe];
        $enriched = $this->attachDetails($recipes);
        return $enriched[0];
    }

    public function getTrending() {
        $query = "SELECT * FROM " . $this->table_name . " ORDER BY created_at DESC LIMIT 5";
        $stmt = $this->conn->prepare($query);
        $stmt->execute();
        $recipes = $stmt->fetchAll(PDO::FETCH_ASSOC);
        return $this->attachDetails($recipes);
    }

    public function getRecommended() {
        $query = "SELECT * FROM " . $this->table_name . " LIMIT 10";
        $stmt = $this->conn->prepare($query);
        $stmt->execute();
        $recipes = $stmt->fetchAll(PDO::FETCH_ASSOC);
        return $this->attachDetails($recipes);
    }

    public function getByIngredients($ingredients) {
        if (empty($ingredients)) return [];
        
        $placeholders = implode(',', array_fill(0, count($ingredients), '?'));
        $query = "SELECT r.* FROM recipes r
                  JOIN recipe_ingredients ri ON r.id = ri.recipe_id
                  JOIN ingredients i ON ri.ingredient_id = i.id
                  WHERE i.name IN ($placeholders)
                  GROUP BY r.id";
                  
        $stmt = $this->conn->prepare($query);
        $stmt->execute($ingredients);
        $recipes = $stmt->fetchAll(PDO::FETCH_ASSOC);
        return $this->attachDetails($recipes);
    }

    public function getByAuthorId($authorId) {
        $query = "SELECT * FROM " . $this->table_name . " WHERE author_id = ? ORDER BY created_at DESC";
        $stmt = $this->conn->prepare($query);
        $stmt->execute([$authorId]);
        $recipes = $stmt->fetchAll(PDO::FETCH_ASSOC);
        return $this->attachDetails($recipes);
    }

    public function getAll() {
        $query = "SELECT * FROM " . $this->table_name . " ORDER BY created_at DESC";
        $stmt = $this->conn->prepare($query);
        $stmt->execute();
        $recipes = $stmt->fetchAll(PDO::FETCH_ASSOC);
        return $this->attachDetails($recipes);
    }

    public function search($keyword) {
        if (empty(trim($keyword))) return [];
        $searchTerm = "%{$keyword}%";
        $query = "SELECT * FROM " . $this->table_name . " WHERE title LIKE ? OR description LIKE ? OR category LIKE ? ORDER BY created_at DESC";
        $stmt = $this->conn->prepare($query);
        $stmt->execute([$searchTerm, $searchTerm, $searchTerm]);
        $recipes = $stmt->fetchAll(PDO::FETCH_ASSOC);
        return $this->attachDetails($recipes);
    }

    public function getSavedByUser($userId) {
        $query = "SELECT r.* FROM recipes r
                  JOIN bookmarks b ON r.id = b.recipe_id
                  WHERE b.user_id = ?
                  ORDER BY b.created_at DESC";
        $stmt = $this->conn->prepare($query);
        $stmt->execute([$userId]);
        $recipes = $stmt->fetchAll(PDO::FETCH_ASSOC);
        return $this->attachDetails($recipes);
    }

    public function update($id, $userId, $data) {
        try {
            $this->conn->beginTransaction();

            // 1. Update basic info with ownership check
            $query = "UPDATE " . $this->table_name . " 
                      SET title = ?, description = ?, category = ?, prep_time = ?, difficulty = ?, kcal = ?, image_url = ? 
                      WHERE id = ? AND author_id = ?";
            $stmt = $this->conn->prepare($query);
            $stmt->execute([
                $data['title'],
                $data['description'] ?? '',
                $data['category'] ?? '',
                $data['prep_time'] ?? 0,
                $data['difficulty'] ?? '',
                $data['kcal'] ?? 0,
                $data['image_url'] ?? '',
                $id,
                $userId
            ]);

            if ($stmt->rowCount() == 0) {
                // If no row was updated, check if it's because item not found or not owned
                $check = $this->getById($id);
                if (!$check || $check['author_id'] != $userId) {
                    throw new Exception("Recipe not found or you don't have permission");
                }
                // If owned but no values changed, rowCount is 0, which is technically fine in MySQL
            }

            // 2. Clear old ingredients and steps
            $stmt = $this->conn->prepare("DELETE FROM recipe_ingredients WHERE recipe_id = ?");
            $stmt->execute([$id]);
            $stmt = $this->conn->prepare("DELETE FROM cooking_steps WHERE recipe_id = ?");
            $stmt->execute([$id]);

            // 3. Re-insert Ingredients (reuse creation logic pattern)
            if (!empty($data['ingredients'])) {
                foreach ($data['ingredients'] as $ing) {
                    $stmt = $this->conn->prepare("SELECT id FROM ingredients WHERE name = ?");
                    $stmt->execute([$ing['name']]);
                    $ingredientId = $stmt->fetchColumn();
                    if (!$ingredientId) {
                        $stmt = $this->conn->prepare("INSERT INTO ingredients (name) VALUES (?)");
                        $stmt->execute([$ing['name']]);
                        $ingredientId = $this->conn->lastInsertId();
                    }
                    $stmt = $this->conn->prepare("INSERT INTO recipe_ingredients (recipe_id, ingredient_id, amount) VALUES (?, ?, ?)");
                    $stmt->execute([$id, $ingredientId, $ing['amount'] ?? '']);
                }
            }

            // 4. Re-insert Steps
            if (!empty($data['steps'])) {
                $stepNumber = 1;
                foreach ($data['steps'] as $step) {
                    $stmt = $this->conn->prepare("INSERT INTO cooking_steps (recipe_id, step_number, description) VALUES (?, ?, ?)");
                    $stmt->execute([$id, $stepNumber++, $step]);
                }
            }

            $this->conn->commit();
            return ["status" => "success", "message" => "Recipe updated"];
        } catch (Exception $e) {
            if ($this->conn->inTransaction()) $this->conn->rollBack();
            return ["status" => "error", "message" => $e->getMessage()];
        }
    }

    public function delete($id, $userId) {
        try {
            $this->conn->beginTransaction();

            // 1. Delete associated data first
            $stmt = $this->conn->prepare("DELETE FROM recipe_ingredients WHERE recipe_id = ?");
            $stmt->execute([$id]);
            $stmt = $this->conn->prepare("DELETE FROM cooking_steps WHERE recipe_id = ?");
            $stmt->execute([$id]);
            $stmt = $this->conn->prepare("DELETE FROM bookmarks WHERE recipe_id = ?");
            $stmt->execute([$id]);

            // 2. Delete main recipe with ownership check
            $query = "DELETE FROM " . $this->table_name . " WHERE id = ? AND author_id = ?";
            $stmt = $this->conn->prepare($query);
            $stmt->execute([$id, $userId]);

            if ($stmt->rowCount() == 0) {
                throw new Exception("Recipe not found or you don't have permission");
            }

            $this->conn->commit();
            return ["status" => "success", "message" => "Recipe deleted"];
        } catch (Exception $e) {
            if ($this->conn->inTransaction()) $this->conn->rollBack();
            return ["status" => "error", "message" => $e->getMessage()];
        }
    }

    public function create($data) {
        file_put_contents(__DIR__ . '/../../debug.log', "CREATE ATTEMPT: " . json_encode($data) . "\n", FILE_APPEND);
        try {
            $this->conn->beginTransaction();

            // 1. Insert into recipes
            $query = "INSERT INTO " . $this->table_name . " 
                      (author_id, title, description, category, prep_time, difficulty, kcal, image_url) 
                      VALUES (?, ?, ?, ?, ?, ?, ?, ?)";
            $stmt = $this->conn->prepare($query);
            $stmt->execute([
                $data['author_id'] ?? 1,
                $data['title'],
                $data['description'] ?? '',
                $data['category'] ?? '',
                $data['prep_time'] ?? 0,
                $data['difficulty'] ?? '',
                $data['kcal'] ?? 0,
                $data['image_url'] ?? ''
            ]);
            $recipeId = $this->conn->lastInsertId();
            file_put_contents(__DIR__ . '/../../debug.log', "RECIPE INSERTED: ID=$recipeId\n", FILE_APPEND);

            // 2. Handle Ingredients
            if (!empty($data['ingredients'])) {
                foreach ($data['ingredients'] as $ing) {
                    // Check if ingredient exists
                    $stmt = $this->conn->prepare("SELECT id FROM ingredients WHERE name = ?");
                    $stmt->execute([$ing['name']]);
                    $ingredientId = $stmt->fetchColumn();

                    if (!$ingredientId) {
                        $stmt = $this->conn->prepare("INSERT INTO ingredients (name) VALUES (?)");
                        $stmt->execute([$ing['name']]);
                        $ingredientId = $this->conn->lastInsertId();
                    }

                    // Link to recipe
                    $stmt = $this->conn->prepare("INSERT INTO recipe_ingredients (recipe_id, ingredient_id, amount) VALUES (?, ?, ?)");
                    $stmt->execute([$recipeId, $ingredientId, $ing['amount'] ?? '']);
                }
            }

            // 3. Handle Steps
            if (!empty($data['steps'])) {
                $stepNumber = 1;
                foreach ($data['steps'] as $step) {
                    $stmt = $this->conn->prepare("INSERT INTO cooking_steps (recipe_id, step_number, description) VALUES (?, ?, ?)");
                    $stmt->execute([$recipeId, $stepNumber++, $step]);
                }
            }

            $this->conn->commit();
            file_put_contents(__DIR__ . '/../../debug.log', "CREATE SUCCESS: ID=$recipeId\n", FILE_APPEND);
            return ["status" => "success", "id" => $recipeId];
        } catch (Exception $e) {
            if ($this->conn->inTransaction()) {
                $this->conn->rollBack();
            }
            file_put_contents(__DIR__ . '/../../debug.log', "CREATE ERROR: " . $e->getMessage() . "\n", FILE_APPEND);
            return ["status" => "error", "message" => $e->getMessage()];
        }
    }
}
?>

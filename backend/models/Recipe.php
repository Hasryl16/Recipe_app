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
}
?>

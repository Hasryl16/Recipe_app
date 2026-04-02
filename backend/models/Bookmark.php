<?php
class Bookmark {
    private $conn;
    private $table_name = "bookmarks";

    public function __construct($db) {
        $this->conn = $db;
    }

    public function toggle($userId, $recipeId) {
        try {
            // Check if already bookmarked
            $query = "SELECT id FROM " . $this->table_name . " WHERE user_id = ? AND recipe_id = ?";
            $stmt = $this->conn->prepare($query);
            $stmt->execute([$userId, $recipeId]);
            $row = $stmt->fetch(PDO::FETCH_ASSOC);

            if ($row) {
                // Already bookmarked, remove it
                $query = "DELETE FROM " . $this->table_name . " WHERE id = ?";
                $stmt = $this->conn->prepare($query);
                if ($stmt->execute([$row['id']])) {
                    return ["status" => "removed"];
                }
            } else {
                // Not bookmarked, add it
                $query = "INSERT INTO " . $this->table_name . " (user_id, recipe_id) VALUES (?, ?)";
                $stmt = $this->conn->prepare($query);
                if ($stmt->execute([$userId, $recipeId])) {
                    return ["status" => "added"];
                }
            }
            return ["status" => "error", "message" => "SQL Execution failed"];
        } catch (Exception $e) {
            return ["status" => "error", "message" => $e->getMessage()];
        }
    }

    public function getSavedRecipes($userId) {
        // Enforce lowercase keys and all basic fields to ensure mapping works
        $query = "SELECT r.id, r.author_id, r.title, r.description, r.category, r.prep_time, r.difficulty, r.kcal, r.image_url, r.created_at 
                  FROM recipes r 
                  JOIN bookmarks b ON r.id = b.recipe_id 
                  WHERE b.user_id = ? 
                  ORDER BY b.created_at DESC";
        $stmt = $this->conn->prepare($query);
        $stmt->execute([$userId]);
        $recipes = $stmt->fetchAll(PDO::FETCH_ASSOC);
        
        // Return empty array instead of null
        return $recipes ?: [];
    }

    public function isBookmarked($userId, $recipeId) {
        $query = "SELECT id FROM " . $this->table_name . " WHERE user_id = ? AND recipe_id = ?";
        $stmt = $this->conn->prepare($query);
        $stmt->execute([$userId, $recipeId]);
        return $stmt->fetch(PDO::FETCH_ASSOC) ? true : false;
    }
}
?>

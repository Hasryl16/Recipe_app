<?php
class MealPlan {
    private $conn;
    private $table_name = "meal_plans";

    public function __construct($db) {
        $this->conn = $db;
    }

    public function getByUser($userId) {
        $query = "SELECT mp.*, r.title as recipe_title, r.image_url as recipe_image_url 
                  FROM " . $this->table_name . " mp
                  LEFT JOIN recipes r ON mp.recipe_id = r.id
                  WHERE mp.user_id = ?
                  ORDER BY mp.plan_date ASC";
        $stmt = $this->conn->prepare($query);
        $stmt->execute([$userId]);
        return $stmt->fetchAll(PDO::FETCH_ASSOC);
    }

    public function create($data) {
        $query = "INSERT INTO " . $this->table_name . " 
                  SET user_id=:user_id, recipe_id=:recipe_id, plan_date=:plan_date, meal_type=:meal_type";
        $stmt = $this->conn->prepare($query);

        $stmt->bindParam(":user_id", $data['user_id']);
        $stmt->bindParam(":recipe_id", $data['recipe_id']);
        $stmt->bindParam(":plan_date", $data['plan_date']);
        $stmt->bindParam(":meal_type", $data['meal_type']);

        if ($stmt->execute()) {
            return true;
        }
        return false;
    }
}
?>

<?php
require_once __DIR__ . '/../models/MealPlan.php';

class MealPlanController {
    private $mealPlan;

    public function __construct($db) {
        $this->mealPlan = new MealPlan($db);
    }

    public function getByUser($userId) {
        return $this->mealPlan->getByUser($userId);
    }

    public function create($data) {
        if ($this->mealPlan->create($data)) {
            return ["status" => "success", "message" => "Meal planned successfully"];
        }
        return ["status" => "error", "message" => "Unable to plan meal"];
    }

    public function delete($id) {
        if ($this->mealPlan->delete($id)) {
            return ["status" => "success", "message" => "Meal plan deleted successfully"];
        }
        return ["status" => "error", "message" => "Unable to delete meal plan"];
    }
}
?>

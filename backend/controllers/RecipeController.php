<?php
require_once __DIR__ . '/../models/Recipe.php';

class RecipeController {
    private $recipe;

    public function __construct($db) {
        $this->recipe = new Recipe($db);
    }

    public function getTrending() {
        return $this->recipe->getTrending();
    }

    public function getRecommended() {
        return $this->recipe->getRecommended();
    }

    public function getById($id) {
        return $this->recipe->getById($id);
    }

    public function searchByIngredients($data) {
        $ingredients = $data['ingredients'] ?? [];
        return $this->recipe->getByIngredients($ingredients);
    }

    public function create($data) {
        return $this->recipe->create($data);
    }

    public function getByAuthor($id) {
        return $this->recipe->getByAuthorId($id);
    }

    public function search($keyword) {
        return $this->recipe->search($keyword);
    }
}
?>

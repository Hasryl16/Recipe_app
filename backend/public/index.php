<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Methods: POST, GET, DELETE, PUT, OPTIONS");
header("Access-Control-Max-Age: 3600");
header("Access-Control-Allow-Headers: Content-Type, Access-Control-Allow-Headers, Authorization, X-Requested-With");

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}

require_once __DIR__ . '/../vendor/autoload.php';
require_once __DIR__ . '/../config/Database.php';
require_once __DIR__ . '/../controllers/AuthController.php';
require_once __DIR__ . '/../controllers/RecipeController.php';
require_once __DIR__ . '/../controllers/MealPlanController.php';
require_once __DIR__ . '/../models/Bookmark.php';
require_once __DIR__ . '/../middleware/AuthMiddleware.php';

// Load Env
$dotenv = Dotenv\Dotenv::createImmutable(__DIR__ . '/../');
$dotenv->load();

$database = new Database();
$db = $database->getConnection();

$authController = new AuthController($db);
$recipeController = new RecipeController($db);
$mealPlanController = new MealPlanController($db);
$bookmarkModel = new Bookmark($db);

$uri = parse_url($_SERVER['REQUEST_URI'], PHP_URL_PATH);
$uri = explode('/', $uri);
$endpoint = end($uri);

$input = json_decode(file_get_contents("php://input"), true);

switch ($endpoint) {
    case 'register':
        echo json_encode($authController->register($input));
        break;
    case 'login':
        $username = $input['username'] ?? '';
        $password = $input['password'] ?? '';
        echo json_encode($authController->login($username, $password));
        break;
    case 'trending':
        echo json_encode($recipeController->getTrending());
        break;
    case 'recommended':
        echo json_encode($recipeController->getRecommended());
        break;
    case 'recipe':
        $id = $_GET['id'] ?? 0;
        echo json_encode($recipeController->getById($id));
        break;
    case 'fridge':
        echo json_encode($recipeController->searchByIngredients($input));
        break;
    case 'search':
        $keyword = $_GET['q'] ?? '';
        echo json_encode($recipeController->search($keyword));
        break;
    case 'meal-plan':
        $userId = $_GET['user_id'] ?? 0;
        if ($_SERVER['REQUEST_METHOD'] === 'POST') {
            echo json_encode($mealPlanController->create($input));
        }
        else if ($_SERVER['REQUEST_METHOD'] === 'DELETE') {
            $id = $_GET['id'] ?? 0;
            echo json_encode($mealPlanController->delete($id));
        }
        else {
            echo json_encode($mealPlanController->getByUser($userId));
        }
        break;
    case 'recipes':
        if ($_SERVER['REQUEST_METHOD'] === 'POST') {
            echo json_encode($recipeController->create($input));
        } else {
            $authorId = $_GET['author_id'] ?? 0;
            echo json_encode($recipeController->getByAuthor($authorId));
        }
        break;
    case 'profile-stats':
        $decoded = AuthMiddleware::authenticate();
        $user = new User($db);
        echo json_encode($user->getStats($decoded->uid));
        break;
    case 'profile-update':
        $decoded = AuthMiddleware::authenticate();
        $user = new User($db);
        $user->id = $decoded->uid;
        $user->username = $input['username'] ?? $decoded->username;
        $user->bio = $input['bio'] ?? null;
        $user->profile_picture = $input['profile_picture'] ?? null;
        if ($user->update()) {
            echo json_encode(["status" => "success", "message" => "Profile updated"]);
        } else {
            echo json_encode(["status" => "error", "message" => "Update failed"]);
        }
        break;
    case 'bookmarks':
        $decoded = AuthMiddleware::authenticate();
        if ($_SERVER['REQUEST_METHOD'] === 'POST') {
            $recipeId = $input['recipe_id'] ?? 0;
            echo json_encode($bookmarkModel->toggle($decoded->uid, $recipeId));
        } else {
            // Using Recipe model for enriched details
            $recipeModel = new Recipe($db);
            echo json_encode($recipeModel->getSavedByUser($decoded->uid));
        }
        break;
    case 'profile':
        $decoded = AuthMiddleware::authenticate();
        echo json_encode([
            "message" => "This is a protected route",
            "user_id" => $decoded->uid,
            "username" => $decoded->username
        ]);
        break;
    default:
        http_response_code(404);
        echo json_encode(["message" => "Not Found"]);
        break;
}
?>

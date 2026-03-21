<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Methods: POST, GET, OPTIONS");
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
require_once __DIR__ . '/../middleware/AuthMiddleware.php';

// Load Env
$dotenv = Dotenv\Dotenv::createImmutable(__DIR__ . '/../');
$dotenv->load();

$database = new Database();
$db = $database->getConnection();

$authController = new AuthController($db);
$recipeController = new RecipeController($db);
$mealPlanController = new MealPlanController($db);

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
    case 'meal-plan':
        $userId = $_GET['user_id'] ?? 0;
        if ($_SERVER['REQUEST_METHOD'] === 'POST') {
            echo json_encode($mealPlanController->create($input));
        } else {
            echo json_encode($mealPlanController->getByUser($userId));
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

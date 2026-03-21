<?php
require_once __DIR__ . '/../vendor/autoload.php';
use Firebase\JWT\JWT;
require_once __DIR__ . '/../models/User.php';

class AuthController {
    private $db;
    private $user;

    public function __construct($db) {
        $this->db = $db;
        $this->user = new User($db);
    }

    public function login($username, $password) {
        $userData = $this->user->findByUsername($username);
        
        if($userData && password_verify($password, $userData['password'])) {
            $payload = [
                "iss" => "recipe_app",
                "iat" => time(),
                "exp" => time() + (int)$_ENV['JWT_EXPIRE'],
                "uid" => $userData['id'],
                "username" => $userData['username']
            ];
            
            $jwt = JWT::encode($payload, $_ENV['JWT_SECRET'], 'HS256');
            
            unset($userData['password']);
            return [
                "status" => "success",
                "token" => $jwt,
                "user" => $userData
            ];
        }
        
        return ["status" => "error", "message" => "Invalid credentials"];
    }

    public function register($data) {
        if (empty($data['username']) || empty($data['password'])) {
            return ["status" => "error", "message" => "Incomplete data"];
        }

        $this->user->username = $data['username'];
        $this->user->password = $data['password'];
        $this->user->bio = $data['bio'] ?? null;
        $this->user->profile_picture = $data['profile_picture'] ?? null;

        if ($this->user->create()) {
            return $this->login($data['username'], $data['password']);
        }
        
        return ["status" => "error", "message" => "Unable to register user"];
    }
}
?>

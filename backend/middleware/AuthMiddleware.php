<?php
use Firebase\JWT\JWT;
use Firebase\JWT\Key;

class AuthMiddleware {
    public static function authenticate() {
        $headers = getallheaders();
        $authHeader = $headers['Authorization'] ?? $headers['authorization'] ?? '';

        if (preg_match('/Bearer\s(\S+)/', $authHeader, $matches)) {
            $jwt = $matches[1];
            try {
                $decoded = JWT::decode($jwt, new Key($_ENV['JWT_SECRET'], 'HS256'));
                return $decoded;
            } catch (Exception $e) {
                http_response_code(401);
                echo json_encode(["message" => "Access denied. Invalid token.", "error" => $e->getMessage()]);
                exit();
            }
        }

        http_response_code(401);
        echo json_encode(["message" => "Access denied. No token provided."]);
        exit();
    }
}
?>

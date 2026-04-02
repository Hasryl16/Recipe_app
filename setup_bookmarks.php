<?php
require_once __DIR__ . '/backend/config/Database.php';

// Mock ENV for script execution if needed
$_ENV['DB_HOST'] = '127.0.0.1';
$_ENV['DB_PORT'] = '3308';
$_ENV['DB_NAME'] = 'recipe_db';
$_ENV['DB_USER'] = 'root';
$_ENV['DB_PASS'] = '1234';

$database = new Database();
$db = $database->getConnection();

if (!$db) {
    die("Connection failed\n");
}

try {
    $sql = "CREATE TABLE IF NOT EXISTS bookmarks (
        id INT AUTO_INCREMENT PRIMARY KEY,
        user_id INT NOT NULL,
        recipe_id INT NOT NULL,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        UNIQUE KEY user_recipe (user_id, recipe_id),
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
        FOREIGN KEY (recipe_id) REFERENCES recipes(id) ON DELETE CASCADE
    ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;";
    
    $db->exec($sql);
    echo "Table 'bookmarks' created successfully or already exists.\n";
} catch (PDOException $e) {
    echo "Error creating table: " . $e->getMessage() . "\n";
}
?>

<?php
class User {
    private $conn;
    private $table_name = "users";

    public $id;
    public $firebase_uid;
    public $username;
    public $password;
    public $bio;
    public $profile_picture;

    public function __construct($db) {
        $this->conn = $db;
    }

    public function create() {
        $query = "INSERT INTO " . $this->table_name . " 
                  SET firebase_uid=:firebase_uid, username=:username, password=:password, bio=:bio, profile_picture=:profile_picture";
        $stmt = $this->conn->prepare($query);

        $this->username = htmlspecialchars(strip_tags($this->username));
        $this->password = password_hash($this->password, PASSWORD_BCRYPT);
        $this->bio = $this->bio ? htmlspecialchars(strip_tags($this->bio)) : null;
        $this->profile_picture = $this->profile_picture ? htmlspecialchars(strip_tags($this->profile_picture)) : null;
        $this->firebase_uid = $this->firebase_uid ?? uniqid('user_');

        $stmt->bindParam(":firebase_uid", $this->firebase_uid);
        $stmt->bindParam(":username", $this->username);
        $stmt->bindParam(":password", $this->password);
        $stmt->bindParam(":bio", $this->bio);
        $stmt->bindParam(":profile_picture", $this->profile_picture);

        if ($stmt->execute()) {
            return true;
        }
        return false;
    }

    public function update() {
        $query = "UPDATE " . $this->table_name . " 
                  SET username=:username, bio=:bio, profile_picture=:profile_picture 
                  WHERE id=:id";
        $stmt = $this->conn->prepare($query);

        $this->username = htmlspecialchars(strip_tags($this->username));
        $this->bio = $this->bio ? htmlspecialchars(strip_tags($this->bio)) : null;
        $this->profile_picture = $this->profile_picture ? htmlspecialchars(strip_tags($this->profile_picture)) : null;

        $stmt->bindParam(":username", $this->username);
        $stmt->bindParam(":bio", $this->bio);
        $stmt->bindParam(":profile_picture", $this->profile_picture);
        $stmt->bindParam(":id", $this->id);

        if ($stmt->execute()) {
            return true;
        }
        return false;
    }

    public function findByUsername($username) {
        $query = "SELECT id, firebase_uid, username, password, bio, profile_picture FROM " . $this->table_name . " WHERE username = ? LIMIT 0,1";
        $stmt = $this->conn->prepare($query);
        $stmt->bindParam(1, $username);
        $stmt->execute();
        return $stmt->fetch(PDO::FETCH_ASSOC);
    }

    public function findById($id) {
        $query = "SELECT id, firebase_uid, username, bio, profile_picture FROM " . $this->table_name . " WHERE id = ? LIMIT 0,1";
        $stmt = $this->conn->prepare($query);
        $stmt->bindParam(1, $id);
        $stmt->execute();
        return $stmt->fetch(PDO::FETCH_ASSOC);
    }

    public function getStats($id) {
        // Count recipes
        $query = "SELECT COUNT(*) as recipe_count FROM recipes WHERE author_id = ?";
        $stmt = $this->conn->prepare($query);
        $stmt->execute([$id]);
        $recipeCount = $stmt->fetchColumn();

        // Count bookmarks (saved)
        $query = "SELECT COUNT(*) as bookmark_count FROM bookmarks WHERE user_id = ?";
        $stmt = $this->conn->prepare($query);
        $stmt->execute([$id]);
        $bookmarkCount = $stmt->fetchColumn();

        return [
            "recipe_count" => (int)$recipeCount,
            "bookmark_count" => (int)$bookmarkCount,
            "follower_count" => 1200 // Mocked for now as requested
        ];
    }
}
?>

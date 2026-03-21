-- Database Initialization Script for Recipe App
CREATE DATABASE IF NOT EXISTS recipe_db;
USE recipe_db;

-- Clear existing data (in order of dependencies)
SET FOREIGN_KEY_CHECKS = 0;
DELETE FROM cooking_steps;
DELETE FROM recipe_ingredients;
DELETE FROM ingredients;
DELETE FROM meal_plans;
DELETE FROM saved_recipes;
DELETE FROM recipes;
DELETE FROM users;

-- Reset Auto-Increment counters to ensure IDs start from 1 again
ALTER TABLE users AUTO_INCREMENT = 1;
ALTER TABLE recipes AUTO_INCREMENT = 1;
ALTER TABLE ingredients AUTO_INCREMENT = 1;
ALTER TABLE cooking_steps AUTO_INCREMENT = 1;
ALTER TABLE meal_plans AUTO_INCREMENT = 1;
SET FOREIGN_KEY_CHECKS = 1;

-- 1. Users Table
CREATE TABLE IF NOT EXISTS users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    firebase_uid VARCHAR(255) DEFAULT NULL UNIQUE,
    username VARCHAR(100) NOT NULL UNIQUE,
    password VARCHAR(255) DEFAULT NULL,
    bio TEXT,
    profile_picture VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 2. Recipes Table
CREATE TABLE IF NOT EXISTS recipes (
    id INT AUTO_INCREMENT PRIMARY KEY,
    author_id INT NOT NULL,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    category VARCHAR(50),
    prep_time INT, -- in minutes
    difficulty ENUM('Easy', 'Medium', 'Hard'),
    kcal INT,
    image_url VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (author_id) REFERENCES users(id) ON DELETE CASCADE
);

-- 3. Ingredients Master Table
CREATE TABLE IF NOT EXISTS ingredients (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE
);

-- 4. Recipe Ingredients (Many-to-Many)
CREATE TABLE IF NOT EXISTS recipe_ingredients (
    recipe_id INT NOT NULL,
    ingredient_id INT NOT NULL,
    amount VARCHAR(100),
    PRIMARY KEY (recipe_id, ingredient_id),
    FOREIGN KEY (recipe_id) REFERENCES recipes(id) ON DELETE CASCADE,
    FOREIGN KEY (ingredient_id) REFERENCES ingredients(id) ON DELETE CASCADE
);

-- 5. Cooking Steps Table
CREATE TABLE IF NOT EXISTS cooking_steps (
    id INT AUTO_INCREMENT PRIMARY KEY,
    recipe_id INT NOT NULL,
    step_number INT NOT NULL,
    description TEXT NOT NULL,
    FOREIGN KEY (recipe_id) REFERENCES recipes(id) ON DELETE CASCADE
);

-- 6. Meal Plans Table
CREATE TABLE IF NOT EXISTS meal_plans (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    recipe_id INT NOT NULL,
    plan_date DATE NOT NULL,
    meal_type ENUM('Breakfast', 'Lunch', 'Dinner', 'Snack') NOT NULL,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (recipe_id) REFERENCES recipes(id) ON DELETE CASCADE
);

-- 7. Saved Recipes Table (Favorites)
CREATE TABLE IF NOT EXISTS saved_recipes (
    user_id INT NOT NULL,
    recipe_id INT NOT NULL,
    saved_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (user_id, recipe_id),
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (recipe_id) REFERENCES recipes(id) ON DELETE CASCADE
);

-- Insert Some Initial Master Data
INSERT IGNORE INTO ingredients (name) VALUES 
('Salmon Fillet'), ('Mixed Spring Greens'), ('Cherry Tomatoes'), ('Avocado'), 
('Lemon'), ('Honey'), ('Olive Oil'), ('Sea Salt'), ('Black Pepper'),
('Eggs'), ('Whole Wheat Bread'), ('Greek Yogurt'), ('Granola'),
('Chicken Breast'), ('Quinoa'), ('Cucumber'), ('Red Onion'), ('Feta Cheese'),
('Garlic'), ('Pasta'), ('Parmesan'), ('Basil'), ('Pine Nuts');

-- Seed Users (Password hashing will be handled by the backend)
INSERT IGNORE INTO users (firebase_uid, username, bio, profile_picture) VALUES
('user123', 'Budi Santoso', 'Pecinta masakan nusantara & healthy food blogger.', 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?q=80&w=150&auto=format&fit=crop'),
('user456', 'Siti Aminah', 'Home chef specialized in Mediterranean diet.', 'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?q=80&w=150&auto=format&fit=crop');

-- Seed Recipes
INSERT IGNORE INTO recipes (author_id, title, description, category, prep_time, difficulty, kcal, image_url) VALUES
(1, 'Poached Eggs with Avocado Toast', 'A healthy and delicious breakfast to start your day.', 'Breakfast', 15, 'Easy', 450, 'https://images.unsplash.com/photo-1525351484163-7529414344d8?q=80&w=800&auto=format&fit=crop'),
(1, 'Miso Glazed Salmon', 'Savory and sweet salmon with a perfectly crispy skin.', 'Dinner', 25, 'Medium', 520, 'https://images.unsplash.com/photo-1467003909585-2f8a72700288?q=80&w=800&auto=format&fit=crop'),
(2, 'Mediterranean Quinoa Salad', 'Refreshing and protein-packed salad with fresh veggies.', 'Lunch', 20, 'Easy', 380, 'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?q=80&w=800&auto=format&fit=crop');

-- Seed Recipe Ingredients
INSERT IGNORE INTO recipe_ingredients (recipe_id, ingredient_id, amount) VALUES
(1, 10, '2 large'), -- Eggs
(1, 11, '2 slices'), -- Bread
(1, 4, '1/2'), -- Avocado
(2, 1, '1 large'), -- Salmon
(2, 5, '1 tbsp'), -- Lemon
(2, 19, '1 clove'), -- Garlic
(3, 15, '1 cup boiled'), -- Quinoa
(3, 16, '1/2 cup diced'), -- Cucumber
(3, 18, '50g crumbled'); -- Feta

-- Seed Cooking Steps
INSERT IGNORE INTO cooking_steps (recipe_id, step_number, description) VALUES
(1, 1, 'Toast the bread slices until golden brown.'),
(1, 2, 'Poach the eggs in simmering water for 3-4 minutes.'),
(1, 3, 'Mash avocado and spread it on the toast.'),
(1, 4, 'Top with poached eggs and season with sea salt and black pepper.'),
(2, 1, 'Season salmon with salt and lemon juice.'),
(2, 2, 'Sear in a hot pan for 4 minutes per side.'),
(3, 1, 'Toss cooked quinoa with chopped cucumber and feta.'),
(3, 2, 'Drizzle with olive oil and serve cold.');

-- Seed Meal Plans
INSERT IGNORE INTO meal_plans (user_id, recipe_id, plan_date, meal_type) VALUES
(1, 1, CURDATE(), 'Breakfast'),
(1, 3, CURDATE(), 'Lunch'),
(1, 2, CURDATE(), 'Dinner');

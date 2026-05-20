-- Create database (if not exists)
CREATE DATABASE IF NOT EXISTS dbarisan;
USE dbarisan;

-- Users table
CREATE TABLE IF NOT EXISTS users (
    id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE,
    email VARCHAR(100) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    created_at TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP
);

-- Arisan groups table
CREATE TABLE IF NOT EXISTS arisan_groups (
    id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    group_name VARCHAR(100) NOT NULL,
    contribution_amount INT NOT NULL,
    start_month VARCHAR(50) NOT NULL,
    total_participants INT NOT NULL,
    current_month INT NOT NULL DEFAULT 1,
    created_at TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- Participants table
CREATE TABLE IF NOT EXISTS arisan_participants (
    id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    group_id INT NOT NULL,
    user_id INT DEFAULT NULL,
    participant_name VARCHAR(100) NOT NULL,
    phone_number VARCHAR(20) DEFAULT NULL,
    is_admin TINYINT(1) NOT NULL DEFAULT 0,
    has_won TINYINT(1) NOT NULL DEFAULT 0,
    winning_month INT DEFAULT NULL,
    created_at TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (group_id) REFERENCES arisan_groups(id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE SET NULL
);

-- Payments table
CREATE TABLE IF NOT EXISTS arisan_payments (
    id INT NOT NULL AUTO_INCREMENT PRIMARY KEY,
    group_id INT NOT NULL,
    participant_id INT NOT NULL,
    month INT NOT NULL,
    amount INT NOT NULL,
    payment_date TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
    payment_status ENUM('pending', 'completed', 'failed') NOT NULL DEFAULT 'pending',
    FOREIGN KEY (group_id) REFERENCES arisan_groups(id) ON DELETE CASCADE,
    FOREIGN KEY (participant_id) REFERENCES arisan_participants(id) ON DELETE CASCADE
);

-- Insert some sample data for testing
INSERT INTO users (username, email, password, created_at) VALUES 
('admin', 'admin@example.com', '$2y$10$6Y5dKmYM5lS6aKVjwFQIe.KdDvnHfVRcZOhYHT4SqeZC3SpRBX6iC', NOW()); -- password: admin123

-- Sample groups
INSERT INTO arisan_groups (user_id, group_name, contribution_amount, start_month, total_participants, current_month, created_at) VALUES
(1, 'Arisan Bulanan', 100000, 'January 2023', 5, 1, NOW()),
(1, 'Arisan Mingguan', 50000, 'February 2023', 10, 1, NOW());

-- Sample participants
INSERT INTO arisan_participants (group_id, participant_name, phone_number, is_admin, has_won, created_at) VALUES
(1, 'Peserta 1', '081234567890', 0, 0, NOW()),
(1, 'Peserta 2', '081234567891', 0, 0, NOW()),
(1, 'Peserta 3', '081234567892', 0, 0, NOW()),
(1, 'Peserta 4', '081234567893', 0, 0, NOW()),
(1, 'Peserta 5', '081234567894', 0, 0, NOW()),
(2, 'Anggota 1', '081234567895', 0, 0, NOW()),
(2, 'Anggota 2', '081234567896', 0, 0, NOW()),
(2, 'Anggota 3', '081234567897', 0, 0, NOW());

-- Sample payments
INSERT INTO arisan_payments (group_id, participant_id, month, amount, payment_status, payment_date) VALUES
(1, 1, 1, 100000, 'completed', NOW()),
(1, 2, 1, 100000, 'completed', NOW()),
(1, 3, 1, 100000, 'pending', NOW()),
(1, 4, 1, 100000, 'completed', NOW()),
(1, 5, 1, 100000, 'pending', NOW()),
(2, 6, 1, 50000, 'completed', NOW()),
(2, 7, 1, 50000, 'completed', NOW()),
(2, 8, 1, 50000, 'pending', NOW());

-- Create index for better performance
CREATE INDEX idx_participant_group ON arisan_participants(group_id);
CREATE INDEX idx_payment_group ON arisan_payments(group_id);
CREATE INDEX idx_payment_participant ON arisan_payments(participant_id); 
-- MySQL initialization script
-- This script runs automatically when MySQL container starts

-- Create database if not exists
CREATE DATABASE IF NOT EXISTS bomcalendar;
USE bomcalendar;

-- Create users table
CREATE TABLE IF NOT EXISTS users (
    id INT PRIMARY KEY AUTO_INCREMENT,
    email VARCHAR(255) UNIQUE NOT NULL,
    name VARCHAR(100) NOT NULL,
    password_hash VARCHAR(255),
    status ENUM('active', 'inactive', 'suspended') DEFAULT 'active',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_email (email),
    INDEX idx_status (status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Create periods table
CREATE TABLE IF NOT EXISTS periods (
    id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    cycle_length INT DEFAULT 28,
    flow_type VARCHAR(50),
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_user_id (user_id),
    INDEX idx_start_date (start_date)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Create events table
CREATE TABLE IF NOT EXISTS events (
    id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    event_type VARCHAR(50) NOT NULL,
    event_date DATE NOT NULL,
    description TEXT,
    metadata JSON,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_user_event (user_id, event_type),
    INDEX idx_event_date (event_date)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Create notifications table
CREATE TABLE IF NOT EXISTS notifications (
    id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    type VARCHAR(50) NOT NULL,
    title VARCHAR(255) NOT NULL,
    message TEXT,
    is_read BOOLEAN DEFAULT FALSE,
    sent_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    read_at TIMESTAMP NULL,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    INDEX idx_user_unread (user_id, is_read)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Insert sample data
INSERT INTO users (email, name, password_hash) VALUES
    ('test@example.com', 'Test User', 'hashed_password_here'),
    ('jane@example.com', 'Jane Doe', 'hashed_password_here'),
    ('admin@example.com', 'Admin User', 'hashed_password_here')
ON DUPLICATE KEY UPDATE name = VALUES(name);

-- Insert sample periods
INSERT INTO periods (user_id, start_date, end_date, cycle_length, flow_type, notes) VALUES
    (1, DATE_SUB(CURDATE(), INTERVAL 60 DAY), DATE_SUB(CURDATE(), INTERVAL 55 DAY), 28, 'normal', 'Regular cycle'),
    (1, DATE_SUB(CURDATE(), INTERVAL 32 DAY), DATE_SUB(CURDATE(), INTERVAL 27 DAY), 28, 'normal', 'Regular cycle'),
    (1, DATE_SUB(CURDATE(), INTERVAL 4 DAY), CURDATE(), 28, 'normal', 'Current cycle');

-- Insert sample events
INSERT INTO events (user_id, event_type, event_date, description, metadata) VALUES
    (1, 'symptom', CURDATE(), 'Headache', '{"severity": "mild", "duration": "2 hours"}'),
    (1, 'medication', DATE_SUB(CURDATE(), INTERVAL 1 DAY), 'Pain reliever', '{"name": "Ibuprofen", "dosage": "200mg"}');

-- Create additional sample database
CREATE DATABASE IF NOT EXISTS test_db;
GRANT ALL PRIVILEGES ON test_db.* TO 'admin'@'%';

-- Grant privileges
GRANT ALL PRIVILEGES ON bomcalendar.* TO 'admin'@'%';
FLUSH PRIVILEGES;

-- Show created tables
SHOW TABLES;
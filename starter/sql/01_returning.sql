-- Capstone Project I
-- Starter: SQL Features That Save Code
-- Experiment 1: INSERT ... RETURNING
-- Tested with MariaDB 11.8.10

CREATE DATABASE IF NOT EXISTS capstone_starter;
USE capstone_starter;

-- Create a fresh demonstration table.
DROP TABLE IF EXISTS returning_demo;

CREATE TABLE returning_demo (
    student_id INT AUTO_INCREMENT PRIMARY KEY,
    student_name VARCHAR(100) NOT NULL
);

-- Traditional approach: two statements.
INSERT INTO returning_demo (student_name)
VALUES ('Bob');

SELECT LAST_INSERT_ID() AS generated_id;

-- MariaDB approach: one statement.
INSERT INTO returning_demo (student_name)
VALUES ('Alice')
RETURNING student_id, student_name;

-- Verify that both records exist.
SELECT * FROM returning_demo;

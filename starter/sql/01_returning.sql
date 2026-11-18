-- Capstone Project I
-- Experiment 1: INSERT ... RETURNING
-- Tested with MariaDB 11.8.10

CREATE DATABASE IF NOT EXISTS capstone_starter;
USE capstone_starter;

-- Reset the demonstration table.
DROP TABLE IF EXISTS returning_demo;

CREATE TABLE returning_demo (
    student_id INT AUTO_INCREMENT PRIMARY KEY,
    student_name VARCHAR(100) NOT NULL
);

-- Traditional approach: two SQL statements.
INSERT INTO returning_demo (student_name)
VALUES ('Bob');

SELECT student_id, student_name
FROM returning_demo
WHERE student_id = LAST_INSERT_ID();

-- MariaDB approach: one SQL statement.
INSERT INTO returning_demo (student_name)
VALUES ('Alice')
RETURNING student_id, student_name;

-- Verify that both records were inserted.
SELECT * FROM returning_demo;

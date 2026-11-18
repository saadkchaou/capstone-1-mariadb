
-- Capstone Project I
-- Experiment 2: Native UUID versus CHAR(36)
-- Tested with MariaDB 11.8.10

CREATE DATABASE IF NOT EXISTS capstone_starter;
USE capstone_starter;

-- Reset only the experiment tables.
DROP TABLE IF EXISTS uuid_text_demo;
DROP TABLE IF EXISTS uuid_native_demo;

-- Traditional approach: UUID represented as text.
CREATE TABLE uuid_text_demo (
    student_id CHAR(36) PRIMARY KEY,
    student_name VARCHAR(100) NOT NULL
);

-- MariaDB approach: Native UUID data type.
CREATE TABLE uuid_native_demo (
    student_id UUID PRIMARY KEY,
    student_name VARCHAR(100) NOT NULL
);

-- Generate one UUID for a fair comparison.
SET @student_uuid = UUID();

INSERT INTO uuid_text_demo (student_id, student_name)
VALUES (@student_uuid, 'Alice');

INSERT INTO uuid_native_demo (student_id, student_name)
VALUES (@student_uuid, 'Alice');

-- Verify identical logical values.
SELECT * FROM uuid_text_demo;
SELECT * FROM uuid_native_demo;

-- Compare the declared column types.
SHOW CREATE TABLE uuid_text_demo;
SHOW CREATE TABLE uuid_native_demo;

-- Compare the visible string representation.
SELECT LENGTH(student_id) AS text_length
FROM uuid_text_demo;

SELECT LENGTH(student_id) AS native_display_length
FROM uuid_native_demo;
  

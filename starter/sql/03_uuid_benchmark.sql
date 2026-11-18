-- Capstone Project I
-- UUID storage benchmark
-- MariaDB Server 11.8.10

CREATE DATABASE IF NOT EXISTS capstone_starter;
USE capstone_starter;

-- Remove the previous benchmark tables
DROP TABLE IF EXISTS uuid_text_benchmark;
DROP TABLE IF EXISTS uuid_native_benchmark;

-- Traditional UUID storage
CREATE TABLE uuid_text_benchmark (
    student_id CHAR(36) PRIMARY KEY,
    student_name VARCHAR(100) NOT NULL
) ENGINE=InnoDB;

-- Native MariaDB UUID storage
CREATE TABLE uuid_native_benchmark (
    student_id UUID PRIMARY KEY,
    student_name VARCHAR(100) NOT NULL
) ENGINE=InnoDB;

-- Generate a fresh dataset
DROP TEMPORARY TABLE IF EXISTS benchmark_data;

CREATE TEMPORARY TABLE benchmark_data (
    student_id CHAR(36) PRIMARY KEY,
    student_name VARCHAR(100) NOT NULL
);

SET SESSION max_recursive_iterations = 10001;

INSERT INTO benchmark_data (student_id, student_name)
WITH RECURSIVE numbers AS (
    SELECT 1 AS n
    UNION ALL
    SELECT n + 1
    FROM numbers
    WHERE n < 10000
)
SELECT UUID(), CONCAT('Student ', n)
FROM numbers;

-- Insert identical data into both tables
INSERT INTO uuid_text_benchmark
SELECT * FROM benchmark_data;

INSERT INTO uuid_native_benchmark
SELECT * FROM benchmark_data;

-- Verify row counts
SELECT 'CHAR(36)' AS storage_type, COUNT(*) AS total_rows
FROM uuid_text_benchmark
UNION ALL
SELECT 'UUID', COUNT(*)
FROM uuid_native_benchmark;
USE capstone_starter;

ANALYZE TABLE uuid_text_benchmark, uuid_native_benchmark;

SELECT
    TABLE_NAME,
    ROUND(
        (DATA_LENGTH + INDEX_LENGTH) / 1024,
        2
    ) AS total_kb
FROM information_schema.TABLES
WHERE TABLE_SCHEMA = 'capstone_starter'
  AND TABLE_NAME IN (
      'uuid_text_benchmark',
      'uuid_native_benchmark'
  )
ORDER BY TABLE_NAME;

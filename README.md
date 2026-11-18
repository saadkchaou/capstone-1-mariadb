# Capstone Project I — MariaDB

## Starter Project: SQL Features That Save Code

**University:** Constructor University, Bremen  
**Course:** Capstone Project I — Open Source  
**Project Partner:** MariaDB Foundation  
**Database Version:** MariaDB Server 11.8.10  
**Status:** Starter experiments implemented and tested locally; final evaluation pending

---

## 1. Project Overview

This project investigates how MariaDB-specific SQL features can simplify common database operations.

The goal is to compare traditional SQL implementations against features provided by MariaDB and demonstrate the differences through reproducible examples.

Two features were selected:

1. **INSERT ... RETURNING:** Retrieve information about newly inserted records directly from an INSERT statement.
2. **Native UUID data type:** Store universally unique identifiers using MariaDB's native UUID representation instead of a character column.

The experiments use a simplified student registration scenario.

## 2. Development Environment

| Component | Configuration |
|---|---|
| Operating system | Windows |
| Database server | MariaDB 11.8.10 |
| SQL client | HeidiSQL |
| Database name | `capstone_starter` |
| Dataset | Small, generated demonstration records |

The experiments use generated data and do not require external datasets.

## 3. Project Structure

```text
capstone-1-mariadb/
├── README.md
└── starter/
    └── sql/
        ├── 01_returning.sql
        ├── 02_uuid_comparison.sql
        └── 03_uuid_benchmark.sql
```

The SQL scripts create their own demonstration tables and insert sample data.

## 4. Installation and Setup

### Prerequisites

- MariaDB Server 11.8.10
- HeidiSQL or another MariaDB-compatible SQL client
- Permission to create databases and tables

### Running the experiments

1. Install and start MariaDB Server.
2. Open HeidiSQL.
3. Connect to the local MariaDB server using your database credentials.
4. Download or clone this repository.
5. Open `starter/sql/01_returning.sql` in HeidiSQL.
6. Execute the complete SQL script.
7. Examine the returned results.
8. Repeat with `starter/sql/02_uuid_comparison.sql`.
9. starter/sql/03_uuid_benchmark.sql

Both scripts create the database `capstone_starter` if it does not exist.

**Warning:** Both scripts use `DROP TABLE IF EXISTS` on their respective demonstration tables. Running a script again deletes and recreates the relevant demonstration tables. Do not use these scripts on databases containing valuable data.

The scripts were tested using HeidiSQL's SQL query editor.

## 5. Experiment 1 — INSERT ... RETURNING

### 5.1 Problem

When an application inserts a record into a database, it often needs to retrieve the automatically generated identifier.

A conventional implementation can accomplish this using two SQL statements.

### 5.2 Traditional approach

```sql
INSERT INTO returning_demo (student_name)
VALUES ('Bob');

SELECT student_id, student_name
FROM returning_demo
WHERE student_id = LAST_INSERT_ID();
```

The first statement inserts the student.

The second retrieves the generated identifier and student name using the connection's last automatically generated ID.

### 5.3 MariaDB approach

```sql
INSERT INTO returning_demo (student_name)
VALUES ('Alice')
RETURNING student_id, student_name;
```

MariaDB's `RETURNING` clause allows the inserted information to be returned directly from the INSERT operation.

### 5.4 Comparison

| Criterion | Traditional | RETURNING |
|---|---|---|
| SQL statements | 2 | 1 |
| Inserts a record | Yes | Yes |
| Returns generated ID | Yes | Yes |
| Returns inserted name | Yes | Yes |
| Separate SELECT required | Yes | No |

### 5.5 Findings

Both approaches successfully inserted records and retrieved the generated identifiers and student names.

For this example, `INSERT ... RETURNING` reduces the number of SQL statements from two to one, a reduction of 50%.

It also keeps the insert operation and retrieval of its result within one statement.

The experiment demonstrates reduced SQL statement count, but does not establish a performance advantage in execution time.

### 5.6 Limitations

- The experiment uses a small demonstration table.
- No repeated performance benchmark has been conducted.
- Statement count does not necessarily correspond directly to network round trips.
- `LAST_INSERT_ID()` is connection-specific and remains a valid alternative for many application workflows.
- `RETURNING` is most useful when an application needs information returned immediately from an insert.

## 6. Experiment 2 — Native UUID vs CHAR(36)

### 6.1 Problem

Applications frequently use UUIDs to identify records.

A UUID is a 128-bit identifier commonly displayed as a 36-character string containing hexadecimal characters and hyphens.

A conventional schema can store UUIDs as character data.

MariaDB also provides a native UUID data type.

### 6.2 Traditional approach

```sql
CREATE TABLE uuid_text_demo (
    student_id CHAR(36) PRIMARY KEY,
    student_name VARCHAR(100) NOT NULL
);
```

This design stores the UUID in a character column.

### 6.3 MariaDB approach

```sql
CREATE TABLE uuid_native_demo (
    student_id UUID PRIMARY KEY,
    student_name VARCHAR(100) NOT NULL
);
```

This design uses MariaDB's native UUID type.

### 6.4 Method

The experiment:

1. Creates both tables.
2. Generates a UUID with `UUID()`.
3. Inserts the same UUID and student name into both tables.
4. Retrieves the inserted records.
5. Inspects the table definitions using `SHOW CREATE TABLE`.
6. Examines the displayed value length using `LENGTH()`.

Both implementations successfully store and retrieve the same logical UUID value.

### 6.5 Comparison

| Criterion | CHAR(36) | Native UUID |
|---|---|---|
| Column type | Character | UUID |
| Standard textual form | 36 characters | 36 characters when displayed |
| UUID representation | Character data | Native 16-byte value |
| Designed specifically for UUIDs | No | Yes |
| Can use UUID as primary key | Yes | Yes |

### 6.6 Findings

The native UUID type offers a representation specifically designed for UUID identifiers.

MariaDB documents the native UUID type as using 16 bytes internally, compared with the 36-character textual UUID representation.

For a UUID represented using a single-byte character encoding, that corresponds to 20 fewer bytes for the raw identifier value, before considering table and index overhead.

This is a representation comparison, not a measured reduction in physical database size.

Both approaches returned the UUID in a readable textual form.

### 6.7 Limitations

- The experiment uses only a small amount of generated data.
- Allocated InnoDB storage was measured using a 10,000-record benchmark. Exact physical disk usage and query execution performance were not measured.
- The results do not establish that native UUID queries execute faster.
- `LENGTH()` applied to the UUID's textual representation does not measure its native physical storage.
- Native UUID storage is appropriate when the values are genuinely UUID identifiers; ordinary character columns remain appropriate for general text.
## UUID Storage Benchmark

### Objective

Compare the reported allocated InnoDB storage for 10,000 records using `CHAR(36)` and MariaDB's native `UUID` data type.

### Methodology

Two InnoDB tables were created with identical schemas except for the primary-key data type.

A dataset of 10,000 generated UUIDs and student names was inserted into both tables.

After loading the data, `ANALYZE TABLE` was executed. Storage statistics were retrieved from `information_schema.TABLES` using `DATA_LENGTH + INDEX_LENGTH`.

The experiment was repeated with a newly generated dataset.

### Results

| Storage method | Run 1 | Run 2 |
|---|---:|---:|
| Native UUID | 528 KB | 528 KB |
| CHAR(36) | 1,552 KB | 1,552 KB |

Both tables contained 10,000 records in each run.

In these experiments, the native UUID table used approximately **66% less reported allocated storage** than the character-based table.

### Interpretation

The results demonstrate that MariaDB's native UUID representation can reduce storage requirements for this particular schema and dataset.

However, InnoDB storage statistics reflect allocated index pages and database overhead rather than only the raw UUID values.

The measurements do not establish that UUID queries execute faster, nor do they guarantee the same percentage reduction for larger datasets or different workloads.

### Reproduction

Run `starter/sql/03_uuid_benchmark.sql` in MariaDB 11.8.10.

The script generates the records, loads both tables, verifies row counts and reports their allocated storage.
## 7. Overall Results

| Feature | Main benefit demonstrated |
|---|---|
| INSERT ... RETURNING | Reduces the insert-and-retrieve operation from two SQL statements to one |
| Native UUID | Provides a dedicated 16-byte UUID representation rather than character-based storage |

Both experiments were executed locally on MariaDB Server 11.8.10.

The main demonstrated benefits are reduced SQL complexity and a more appropriate database representation for UUID identifiers.

No general execution-speed advantage is claimed.

## 8. Reproducibility

The SQL scripts are intended to be executable independently.

Each script:

- Creates the project database if needed.
- Selects the project database.
- Recreates only its own demonstration tables.
- Inserts sample records.
- Returns results that can be inspected in a SQL client.

The scripts can be rerun, but doing so replaces the corresponding demonstration data.

## 9. Conclusion

This project demonstrates two ways in which MariaDB features can simplify database development.

`INSERT ... RETURNING` makes insert-and-retrieve operations more concise by returning generated information directly from the statement.

The native `UUID` type provides a dedicated representation for UUID identifiers, avoiding the need to model them as ordinary character strings.

These features are useful when their capabilities match the application's requirements. Neither feature automatically guarantees better performance in every workload.

The experiments illustrate the features through small, reproducible examples and establish a starting point for further benchmarking.

## 10. References

- [MariaDB Server Documentation](https://mariadb.com/docs/server/)
- [MariaDB INSERT ... RETURNING Documentation](https://mariadb.com/docs/server/reference/sql-statements/data-manipulation/inserting-loading-data/insertreturning)
- [MariaDB UUID Data Type Documentation](https://mariadb.com/docs/server/reference/data-types/string-data-types/uuid-data-type)
- [Constructor University MariaDB Project Areas](https://mariadb.org/bachelor_hackathon_2026-09/)

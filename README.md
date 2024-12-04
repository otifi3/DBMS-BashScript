#DBMS Script
This project provides a lightweight, terminal-based database management system (DBMS) implemented in Bash. It allows users to perform essential database operations, such as creating, dropping, and managing databases and tables. The script is designed to demonstrate the functionality of relational database management systems (RDBMS) through a shell-based interface.

#Features
  - Database Management:
    * Create new databases.
    * Drop existing databases.
    * List all databases.
    * Table Management:

  - Create tables with specified column names and types (string or number).
    * List all tables in a database.
    * Drop tables.
    
  - Data Manipulation:
    * Insert records into tables.
    * Update records based on conditions.
    * Select records (all or conditional queries).
    * Delete records (all or based on conditions).
  
  - Validation:
    * Ensures unique primary keys for each table.
    * Prevents invalid column names or types.
    * Restricts operations on nonexistent databases or tables.
   
## How to Use

```bash
# Clone the repository
git clone https://github.com/otifi3/DBMS-BashScript.git

# Create and navigate to the directory
mkdir <directory_name>
cd <directory_name>

# Make the script executable
chmod +x dbms.sh

# Run the script
./dbms.sh

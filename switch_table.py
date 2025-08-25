import os
import sys
import psycopg2

# Check command line arguments
if len(sys.argv) != 3:
    print(f"Uso: python {sys.argv[0]} <source_table> <target_table>")
    sys.exit(1)

source_table = sys.argv[1]
target_table = sys.argv[2]

# Read variables from environment
db_host = os.environ["POSTGRES_HOST"]
db_port = os.environ.get("POSTGRES_PORT", "5432")
db_user = os.environ["POSTGRES_USER"]
db_password = os.environ["TARGET_POSTGRES_PASSWORD"]
db_name = os.environ["POSTGRES_DB"]

conn = None
cur = None

try:
    # Conneection to PostgreSQL
    conn = psycopg2.connect(
        host=db_host,
        port=db_port,
        user=db_user,
        password=db_password,
        dbname=db_name
    )

    # Implicit transaction mode
    conn.autocommit = False
    cur = conn.cursor()

    print(f'Renaming table "{source_table}" to "{target_table}" safely...')

    # SQL: drop target_table if it exists, then rename source_table
    sql = f"""
    DROP TABLE IF EXISTS public."{target_table}";
    ALTER TABLE public."{source_table}" RENAME TO "{target_table}";
    """
    cur.execute(sql)

    conn.commit()
    print(f'Table "{source_table}" successfully renamed to "{target_table}".')

except Exception as e:
    print(f'Error while renaming table: {e}')
    if conn:
        conn.rollback()
    sys.exit(1)

finally:
    if cur:
        cur.close()
    if conn:
        conn.close()

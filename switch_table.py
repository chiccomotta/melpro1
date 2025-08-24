import os
import sys
import psycopg2

# Variabili di ambiente già fornite dal processo Meltano
db_host = os.environ["POSTGRES_HOST"]
db_port = os.environ.get("POSTGRES_PORT", "5432")
db_user = os.environ["POSTGRES_USER"]
db_password = os.environ["POSTGRES_PASSWORD"]
db_name = os.environ["POSTGRES_DB"]

try:
    # Connessione al DB
    conn = psycopg2.connect(
        host=db_host,
        port=db_port,
        user=db_user,
        password=db_password,
        dbname=db_name
    )
    conn.autocommit = False
    cur = conn.cursor()

    source_table = "customers_staging"
    target_table = "customers"

    print(f'Renaming table "{source_table}" to "{target_table}" safely...')

    # SQL: elimina target_table se esiste, poi rinomina source_table
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

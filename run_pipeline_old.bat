@echo off
REM Configuration
set PGPASSWORD=postgres
REM Execute the SQL command to drop the table
echo Dropping table...

psql -h localhost -U postgres -d targetdb -f 'DROP TABLE IF EXISTS "public"."Customers";

if %ERRORLEVEL% NEQ 0 (
    echo Error while executing the SQL command. Terminating the script.
    exit /b 1
)

REM Execute the Meltano pipeline
echo Running the Meltano pipeline...
meltano run tap-mssql target-postgres
if %ERRORLEVEL% NEQ 0 (
    echo Error while executing the Meltano pipeline.
    exit /b 1
)
echo Pipeline completed successfully!

REM Change table schema
psql -h localhost -U postgres -d targetdb -f 'ALTER TABLE "tap_mssql"."Customers" SET SCHEMA public;'
if %ERRORLEVEL% NEQ 0 (
    echo Error while executing the SQL command. Terminating the script.
    exit /b 1
)
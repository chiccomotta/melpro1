@echo off
REM Configuration
set PGPASSWORD=postgres
set TABLE_NAME=Customers
set COPY_TABLE_NAME=CustomersCopy

REM Execute the SQL command to drop the table
echo Dropping table "%TABLE_NAME%"...
psql -h localhost -U postgres -d targetdb -c "DROP TABLE IF EXISTS public.\"%TABLE_NAME%\";"
if %ERRORLEVEL% NEQ 0 (
    echo Error while executing the SQL command to drop the table. Terminating the script.
    exit /b 1
)

REM Execute the Meltano pipeline
echo Running the Meltano pipeline...
meltano run tap-mssql target-postgres
if %ERRORLEVEL% NEQ 0 (
    echo Error while executing the Meltano pipeline.
    exit /b 1
)

REM Change table schema
echo Changing schema for table "%TABLE_NAME%"...
psql -h localhost -U postgres -d targetdb -c "ALTER TABLE tap_mssql.\"%TABLE_NAME%\" SET SCHEMA public;"
if %ERRORLEVEL% NEQ 0 (
    echo Error while executing the SQL command to change the schema. Terminating the script.
    exit /b 1
)

REM Copy table in a transaction
echo Copying table "%TABLE_NAME%" to "%COPY_TABLE_NAME%"...
psql -h localhost -U postgres -d targetdb -c "BEGIN; CREATE TABLE public.\"%COPY_TABLE_NAME%\" (LIKE public.\"%TABLE_NAME%\" INCLUDING ALL); INSERT INTO public.\"%COPY_TABLE_NAME%\" SELECT * FROM public.\"%TABLE_NAME%\"; COMMIT;"
if %ERRORLEVEL% NEQ 0 (
    echo Error while copying the table "%TABLE_NAME%" to "%COPY_TABLE_NAME%". Terminating the script.
    exit /b 1
)

REM Final success message
echo Pipeline completed successfully!

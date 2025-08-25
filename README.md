# Documentazione Progetto Meltano

## Informazioni Generali

* **Versione progetto**: 1
* **Ambiente predefinito**: dev
* **Project ID**: 0198cc50-8b2f-76cc-bfad-9d05541cccf1

## Ambienti Configurati

* **dev**
* **staging**
* **prod**

## Plugin Configurati

### Extractors

#### tap-mssql

* **Variant**: buzzcutnorman
* **Installazione**: `git+https://github.com/BuzzCutNorman/tap-mssql.git`
* **Configurazione**:

  * `host`: `${MSSQL_HOST}`
  * `port`: `${MSSQL_PORT}`
  * `user`: `${MSSQL_USER}`
  * `database`: `${MSSQL_DB}`
  * `include_views`: true
  * `catalog`: `{}` (forza rediscovery ad ogni esecuzione)
  * `discover_mode`: `always` (rediscovery ad ogni esecuzione)
  * `refresh_schema`: true (aggiorna lo schema ad ogni esecuzione)

* **Selezione dati**:

  * `dbo-VwCust.*`

### Loaders

#### target-postgres

* **Variant**: meltanolabs
* **Installazione**: `meltanolabs-target-postgres`
* **Configurazione**:

  * `host`: `${POSTGRES_HOST}`
  * `port`: `${POSTGRES_PORT}`
  * `user`: `${POSTGRES_USER}`
  * `database`: `${POSTGRES_DB}`
  * `default_target_schema`: `public`
  * `batch_size_rows`: 30000
  * `stream_maps`:

    * `dbo-VwCust`:

      * `__alias__`: `customers_staging`

### Utilities

#### switch_table

* **Namespace**: `pg_utilities`
* **Comandi disponibili**:

  * `run_script`

    * **Eseguibile**: python
    * **Argomenti**: `switch_table.py customers_staging customers`

## Workflow Logico

1. **Extractor**:

   * `tap-mssql` estrae i dati da SQL Server (vista `dbo-VwCust`).

2. **Loader**:

   * `target-postgres` carica i dati estratti in PostgreSQL.
   * `stream_maps` rinomina il flusso `dbo-VwCust` in `customers_staging`.

3. **Utility `switch_table`**:

   * Esegue lo script Python `switch_table.py` tramite il comando `run_script`.
   * Lo script gestisce lo **swap** tra la tabella `customers_staging` e la tabella `customers` (produzione).

## Note

* Tutte le credenziali e configurazioni sensibili sono gestite tramite variabili di ambiente (`MSSQL_*` e `POSTGRES_*`).
* Il progetto supporta più ambienti (`dev`, `staging`, `prod`) per consentire test e deployment sicuro.
* Le pipeline possono essere estese aggiungendo ulteriori extractors, loaders o utilities.
* Lanciare con il comando:  ```meltano run tap-mssql target-postgres switch_table:run_script```

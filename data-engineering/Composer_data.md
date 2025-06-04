**Task 1:-** Read from GCS, Transform with BQ, Load to BQ using Compose

Here is a **step-by-steps** for reading a CSV from GCS, transforming it using BigQuery, and orchestrating the pipeline using **Cloud Composer (Airflow)**.

---

### Scenario Overview

* **CSV File**: `employee_data.csv`
* **GCS Bucket**: `airflow_bucket_123` (in `us-east1`)
* **Composer Environment**: `him-composer-env9` (in `us-east1`)
* **Goal**:

  * Load CSV to BigQuery staging table
  * Run a transformation query to a final table
  * Use Airflow DAG in Composer for orchestration

---

## Step 1: Upload CSV to GCS

```bash
gsutil cp employee_data_india.csv gs://airflow_bucket_123/input/
```

---

## Step 2: Load CSV to BigQuery (staging)

You can either do this manually once or automate via Composer DAG.

```bash
bq load --project_id=splendid-sled-460802-q9 --autodetect --source_format=CSV splendid-sled-460802-q9:him_dataset.staging_employees gs://airflow_bucket_123/input/employee_data.csv
```

**create composer**  
```bash
gcloud composer environments create him-composer-env9 \
  --location=us-east1 \
  --image-version=composer-2.13.2-airflow-2.10.5 \
  --env-variables=ENV=dev \
  --service-account=hometown@splendid-sled-460802-q9.iam.gserviceaccount.com \
  --labels=env=prod,team=dataengineering \
  --airflow-configs=core-load_default_connections=false

```

## Step 3: Create Airflow DAG (Composer)

### Create `gcs_bq_transform_dag.py`

```python
from airflow import models
from airflow.providers.google.cloud.operators.bigquery import BigQueryInsertJobOperator
from airflow.providers.google.cloud.transfers.gcs_to_bigquery import GCSToBigQueryOperator
from datetime import datetime, timedelta

default_args = {
    'start_date': datetime(2023, 1, 1),
    'retries': 1,
    'retry_delay': timedelta(minutes=5)
}

with models.DAG(
    dag_id='gcs_to_bq_transform_pipeline',
    default_args=default_args,
    schedule_interval='@once',
    catchup=False,
    tags=['gcs', 'bq', 'composer']
) as dag:

    # Step 1: Load CSV to BigQuery staging table
    load_to_bq = GCSToBigQueryOperator(
        task_id='load_csv_to_bq',
        bucket='airflow_bucket_123',
        source_objects=['input/employee_data.csv'],
        destination_project_dataset_table='splendid-sled-460802-q9.him_dataset.staging_employees',
        source_format='CSV',
        autodetect=True,
        skip_leading_rows=1,
        write_disposition='WRITE_TRUNCATE'
    )

    # Step 2: Run transformation query
    transform_bq = BigQueryInsertJobOperator(
        task_id='transform_bq_data',
        configuration={
            "query": {
                "query": """
                    CREATE OR REPLACE TABLE `splendid-sled-460802-q9.him_dataset.final_employees` AS
                    SELECT empid, ename, UPPER(design) AS design, salary, city, state
                    FROM `splendid-sled-460802-q9.him_dataset.staging_employees`
                    WHERE salary > 50000
                """ ,
                "useLegacySql": False
            }
        },
        location='us-east1'
    )

    load_to_bq >> transform_bq

```

> 🔄 Replace `your_project.my_dataset` with your actual project ID and dataset name.

---

## Step 4: Deploy the DAG to Composer

```bash
gcloud composer environments storage dags import \
  --environment=him-composer-env9 \
  --location=us-east1 \
  --source=gcs_bq_transform_dag.py
```

---

## Step 5: Trigger and Monitor DAG

1. Go to **Cloud Composer → Environments → him-composer-env9**
2. Click **"Airflow UI"**
3. Trigger `gcs_to_bq_transform_pipeline` manually if not on schedule
4. Monitor the tasks `load_csv_to_bq` and `transform_bq_data`

---

To fetch logs for your Composer environment using gcloud:
```bash
gcloud composer environments run him-composer-env9 \
  --location=us-east1 \
  list_dags
```
DAG task logs:
```bash
gcloud composer environments run him-composer-env9 \
  --location=us-east1 \
  list_tasks -- dag_id=gcs_to_bq_transform_pipeline
```
Delete Compose
```bash
gcloud composer environments delete him-composer-env9 \
  --location=us-east1 --quiet
```


**Deploying Composer DAGs and BigQuery Assets**

⁠** Task 2 How to deploy the composer DAGs and BQ create tables, stored procs, DML statements.

---

## Project Details

* **Project ID**: `splendid-sled-460802-q9`
* **Service Account**: `hometown@splendid-sled-460802-q9.iam.gserviceaccount.com`
* **Composer Name**: `him-composer-env9`
* **Bucket Name**: `him-composer-env9`

---

## 1. Enable Required APIs

```bash
gcloud services enable \
  composer.googleapis.com \
  bigquery.googleapis.com \
  storage.googleapis.com \
  iam.googleapis.com \
  cloudresourcemanager.googleapis.com \
  workflows.googleapis.com
```

---

## 2. Set Environment Variables

```bash
export PROJECT_ID="splendid-sled-460802-q9"
export COMPOSER_ENV_NAME="him-composer-env9"   # replace with your Composer env name
export LOCATION="us-east1"                   # e.g., us-east1
export BUCKET=$(gcloud composer environments describe $COMPOSER_ENV_NAME \
  --location $LOCATION --format="value(config.dagGcsPrefix)" | sed 's/\/dags\/$//')
```

---

## 3. Upload DAGs and SQL Files

```bash
# DAG file
gsutil cp dags/deploy_bq_assets_dag.py gs://him-composer-env9/dags

# SQL scripts from sql folder (or) upload the sql's to gs://him-composer-env9/data  
gsutil -m cp sql/*.sql gs://him-composer-env9/data
```

---

## 4. DAG Example for Deploying BigQuery Assets

```python
from airflow import DAG 
from airflow.providers.google.cloud.operators.bigquery import BigQueryInsertJobOperator
from datetime import datetime

with DAG('deploy_bq_assets_dag',
         schedule_interval=None,
         start_date=datetime(2025, 6, 8),
         catchup=False,
         tags=['bq-deploy']) as dag:

    create_tables = BigQueryInsertJobOperator(
        task_id="create_tables",
        configuration={
            "query": {
                "query": "gs://him-composer-env9/data/create_tables.sql",
                "useLegacySql": False,
            }
        },
        location="us-east1",
    )

        run_dml = BigQueryInsertJobOperator(
        task_id="run_dml",
        configuration={
            "query": {
                "query": "gs://him-composer-env9/data/dml_statements.sql",
                "useLegacySql": False,
            }
        },
        location="us-east1",
    )
	
	create_procs = BigQueryInsertJobOperator(
        task_id="create_procs",
        configuration={
            "query": {
                "query": "gs://him-composer-env9/data/create_procs.sql",
                "useLegacySql": False,
            }
        },
        location="us-east1",
    )

    create_tables >> run_dml >> create_procs

```

---

## 5. Verify & Grant IAM Roles to Composer Service Account

```bash
gcloud projects get-iam-policy splendid-sled-460802-q9 \
  --flatten="bindings[].members" \
  --format='table(bindings.role)' \
  --filter="bindings.members:serviceAccount:hometown@splendid-sled-460802-q9.iam.gserviceaccount.com"
```
```bash
ROLE: roles/bigquery.admin
ROLE: roles/cloudbuild.builds.builder
ROLE: roles/composer.ServiceAgentV2Ext
ROLE: roles/composer.serviceAgent
ROLE: roles/composer.worker
ROLE: roles/iam.serviceAccountUser
ROLE: roles/storage.objectViewer
```

```bash
gcloud projects add-iam-policy-binding splendid-sled-460802-q9 \
  --member="serviceAccount:hometown@splendid-sled-460802-q9.iam.gserviceaccount.com" \
  --role="roles/bigquery.admin"
```

> You may also need roles: `roles/storage.objectViewer`, `roles/composer.worker`

---

## 6. Trigger DAG

```bash
gcloud composer environments run $COMPOSER_ENV_NAME \
  --location $LOCATION dags trigger -- deploy_bq_assets_dag
```

---

## 7. Monitor DAG Logs

```bash
gcloud composer environments run $COMPOSER_ENV_NAME \
  --location $LOCATION tasks logs -- deploy_bq_assets_dag create_tables 2025-06-07T12:00:00Z
```

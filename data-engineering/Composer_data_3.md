**Task 3:-** ⁠create a data proc cluster, read data from BQ cluster, do some transformations using, write to BQ and delete the cluster

**Deploying Dataproc Workflow via Cloud Composer**

---

## Environment Details

* **Project ID**: `splendid-sled-460802-q9`
* **Service Account**: `hometown@splendid-sled-460802-q9.iam.gserviceaccount.com`
* **Composer Environment**: `him-composer-env9`
* **GCS Bucket**: `him-composer-env9`

---

## Objective

1. Create a **Dataproc cluster**
2. Run a **PySpark job** that reads from **BigQuery**, transforms data
3. Write transformed data back to **BigQuery**
4. Delete the cluster after completion

---

## Step 1: Enable Required APIs

```bash
gcloud services enable \
  dataproc.googleapis.com \
  bigquery.googleapis.com \
  composer.googleapis.com \
  storage.googleapis.com
```
## Seting Environment (optional)
```bash
export PROJECT_ID="splendid-sled-460802-q9"
export COMPOSER_ENV_NAME="him-composer-env9"
export LOCATION="us-east1"
export DATASET="him_dataset"
export BUCKET=$(gcloud composer environments describe $COMPOSER_ENV_NAME \
  --location $LOCATION --format="value(config.dagGcsPrefix)" | sed 's/\/dags\/$//')
```
---

## Step 2: Upload PySpark Script to GCS

Create a file called `bq_transform_job.py`:

```python
from pyspark.sql import SparkSession
from pyspark.sql.functions import upper

# Step 1: Initialize Spark session
spark = SparkSession.builder \
    .appName("Transform High Salary Employees") \
    .getOrCreate()

# Step 2: Read from BigQuery table: staging_employees
df = spark.read.format("bigquery") \
    .option("table", "splendid-sled-460802-q9.him_dataset.staging_employees") \
    .load()

# Step 3: Apply transformations
# - Filter employees with salary > 75000
# - Convert 'city' and 'state' to uppercase
df_transformed = df.filter(df.salary > 75000) \
    .withColumn("city", upper(df["city"])) \
    .withColumn("state", upper(df["state"]))

# Step 4: Write the transformed data to BigQuery: transformed_employees
df_transformed.write.format("bigquery") \
    .option("table", "splendid-sled-460802-q9.him_dataset.transformed_employees") \
    .mode("overwrite") \
    .save()

```
| Transformation Step              | Purpose                            |
| -------------------------------- | ---------------------------------- |
| `salary > 75000`                 | Filters only high-salaried records |
| `upper(city)` and `upper(state)` | Standardizes text to uppercase     |


Upload the script:

```bash
gsutil cp bq_transform_job.py gs://him-composer-env9/scripts/
```

---

## Step 3: Create Composer DAG `dataproc_bq_dag.py`

```python
from airflow import DAG
from airflow.providers.google.cloud.operators.dataproc import DataprocCreateClusterOperator, DataprocDeleteClusterOperator, DataprocSubmitJobOperator
from airflow.utils.dates import days_ago

PROJECT_ID = "splendid-sled-460802-q9"
REGION = "us-east1"
CLUSTER_NAME = "bq-transform-cluster"
BUCKET_NAME = "him-composer-env9"
SERVICE_ACCOUNT = "hometown@splendid-sled-460802-q9.iam.gserviceaccount.com"

with DAG("dataproc_bq_dag",
         start_date=days_ago(1),
         schedule_interval=None,
         catchup=False,
         tags=["dataproc", "bigquery"]
         ) as dag:

    create_cluster = DataprocCreateClusterOperator(
        task_id="create_cluster",
        project_id=PROJECT_ID,
        cluster_config={
            "master_config": {
                "num_instances": 1,
                "machine_type_uri": "n1-standard-2",
            },
            "worker_config": {
                "num_instances": 2,
                "machine_type_uri": "n1-standard-2",
            },
            "gce_cluster_config": {
                "service_account": SERVICE_ACCOUNT,
                "zone_uri": f"{REGION}-a"
            }
        },
        region=REGION,
        cluster_name=CLUSTER_NAME,
    )

    submit_pyspark_job = DataprocSubmitJobOperator(
        task_id="submit_pyspark_job",
        job={
            "reference": {"project_id": PROJECT_ID},
            "placement": {"cluster_name": CLUSTER_NAME},
            "pyspark_job": {
                "main_python_file_uri": f"gs://{BUCKET_NAME}/scripts/bq_transform_job.py"
            },
        },
        region=REGION,
        project_id=PROJECT_ID,
    )

    delete_cluster = DataprocDeleteClusterOperator(
        task_id="delete_cluster",
        project_id=PROJECT_ID,
        cluster_name=CLUSTER_NAME,
        region=REGION,
        trigger_rule="all_done",
    )

    create_cluster >> submit_pyspark_job >> delete_cluster
```

---

## Step 4: Upload DAG to Composer

```bash
gsutil cp dataproc_bq_dag.py gs://him-composer-env9/dags/
```

---

## Step 5: Trigger the DAG

```bash
gcloud composer environments run him-composer-env9 \
  --location us-east1 dags trigger -- dataproc_bq_dag
```

---



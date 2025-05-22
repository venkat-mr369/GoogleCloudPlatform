To process the `SampleData.xlsx` file using **Apache Beam (Dataflow)** and load the data into **PostgreSQL**, here are the **detailed steps and commands** for the full pipeline:

---

## ✅ Step-by-Step Guide: Load Excel to PostgreSQL via Dataflow

### 🧩 Prerequisites
- GCP Project with **Dataflow API** enabled
- PostgreSQL instance running (Cloud SQL or external)
- GCS bucket for staging the pipeline
- Python environment with Beam SDK
- Cloud SQL Proxy (if using Cloud SQL)
- `openpyxl` for reading Excel files

---

### 1️⃣ **Upload Excel File to GCS**

```bash
gsutil cp SampleData.xlsx gs://<your-bucket-name>/data/SampleData.xlsx
```

---

### 2️⃣ **Install Required Libraries**

```bash
pip install apache-beam[gcp] openpyxl pandas psycopg2-binary
```

---

### 3️⃣ **Python Code (Beam Pipeline)**

Save this as `excel_to_postgres.py`:

```python
import apache_beam as beam
from apache_beam.options.pipeline_options import PipelineOptions
import pandas as pd
import io
import openpyxl
import psycopg2

class ReadExcelFromGCS(beam.DoFn):
    def process(self, element):
        from apache_beam.io.gcp.gcsio import GcsIO

        gcs = GcsIO()
        file_data = gcs.open(element).read()
        df = pd.read_excel(io.BytesIO(file_data))

        for _, row in df.iterrows():
            yield row.to_dict()

class WriteToPostgres(beam.DoFn):
    def __init__(self, db_config):
        self.db_config = db_config

    def start_bundle(self):
        self.conn = psycopg2.connect(**self.db_config)
        self.cursor = self.conn.cursor()

    def process(self, element):
        # Modify according to your table and schema
        self.cursor.execute(
            "INSERT INTO your_table_name (column1, column2) VALUES (%s, %s)",
            (element['Column1'], element['Column2'])
        )
        self.conn.commit()

    def finish_bundle(self):
        self.cursor.close()
        self.conn.close()

def run():
    options = PipelineOptions(
        runner='DataflowRunner',
        project='your-gcp-project',
        temp_location='gs://<your-bucket>/temp',
        region='your-region',
        staging_location='gs://<your-bucket>/staging',
        save_main_session=True
    )

    db_config = {
        "host": "your-db-host",
        "dbname": "your-db-name",
        "user": "your-db-user",
        "password": "your-db-password",
        "port": 5432,
    }

    with beam.Pipeline(options=options) as p:
        (
            p
            | 'Start' >> beam.Create(['gs://<your-bucket>/data/SampleData.xlsx'])
            | 'Read Excel' >> beam.ParDo(ReadExcelFromGCS())
            | 'Write to Postgres' >> beam.ParDo(WriteToPostgres(db_config))
        )

if __name__ == '__main__':
    run()
```

---

### 4️⃣ **Create Table in PostgreSQL**

Adjust the table schema to match your Excel columns:

```sql
CREATE TABLE your_table_name (
    column1 TEXT,
    column2 TEXT
    -- add columns as per your Excel
);
```

---

### 5️⃣ **Run the Dataflow Pipeline**

Use this command to deploy the pipeline to Dataflow:

```bash
python excel_to_postgres.py
```

Or explicitly specify with:

```bash
python excel_to_postgres.py \
  --runner DataflowRunner \
  --project your-gcp-project \
  --region your-region \
  --temp_location gs://<your-bucket>/temp \
  --staging_location gs://<your-bucket>/staging \
  --save_main_session
```

---

## 🛠️ Notes
- If using **Cloud SQL**, configure **private IP** or use **Cloud SQL Auth Proxy**.
- Use **Dataflow Flex Templates** for production and scheduling.
- Make sure **Dataflow workers** can access PostgreSQL (e.g., via VPC connector).

---


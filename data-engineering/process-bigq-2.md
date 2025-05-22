Great! Let’s create a **Dockerized Apache Beam Flex Template** to process `SampleData.xlsx` from GCS and load it into BigQuery.

---

## 📦 What We'll Build

| Component | Description |
|----------|-------------|
| **Flex Template** | Custom Docker container for Dataflow |
| **Input** | Excel file in GCS (`.xlsx`) |
| **Processing** | Read Excel → convert rows to dictionary |
| **Output** | Write to BigQuery table |

---

## ✅ Step-by-Step Setup

---

### 1️⃣ Create Your Beam Pipeline Script

**📄 `excel_to_bq_pipeline.py`**

```python
import apache_beam as beam
from apache_beam.options.pipeline_options import PipelineOptions, SetupOptions
import pandas as pd
import io

class ReadExcelFromGCS(beam.DoFn):
    def process(self, file_path):
        from apache_beam.io.gcp.gcsio import GcsIO
        gcs = GcsIO()
        file_data = gcs.open(file_path).read()
        df = pd.read_excel(io.BytesIO(file_data))
        for _, row in df.iterrows():
            yield {
                'order_date': str(row['OrderDate'].date()),
                'region': row['Region'],
                'rep': row['Rep'],
                'item': row['Item'],
                'units': int(row['Units']),
                'unit_cost': float(row['Unit Cost']),
                'total': float(row['Total']),
            }

def run(argv=None):
    from apache_beam.options.pipeline_options import GoogleCloudOptions, StandardOptions
    import argparse

    parser = argparse.ArgumentParser()
    parser.add_argument('--input_gcs_path', required=True)
    parser.add_argument('--output_bq_table', required=True)
    known_args, pipeline_args = parser.parse_known_args(argv)

    pipeline_options = PipelineOptions(pipeline_args)
    pipeline_options.view_as(SetupOptions).save_main_session = True

    with beam.Pipeline(options=pipeline_options) as p:
        (
            p
            | 'Start' >> beam.Create([known_args.input_gcs_path])
            | 'Parse Excel' >> beam.ParDo(ReadExcelFromGCS())
            | 'Write to BigQuery' >> beam.io.WriteToBigQuery(
                table=known_args.output_bq_table,
                schema='order_date:DATE,region:STRING,rep:STRING,item:STRING,units:INTEGER,unit_cost:NUMERIC,total:NUMERIC',
                create_disposition=beam.io.BigQueryDisposition.CREATE_IF_NEEDED,
                write_disposition=beam.io.BigQueryDisposition.WRITE_APPEND
            )
        )

if __name__ == '__main__':
    run()
```

---

### 2️⃣ Create the `Dockerfile`

```dockerfile
FROM apache/beam_python3.11_sdk:latest

RUN pip install pandas openpyxl

COPY excel_to_bq_pipeline.py /app/excel_to_bq_pipeline.py

ENTRYPOINT ["python", "/app/excel_to_bq_pipeline.py"]
```

---

### 3️⃣ Build and Push to GCR

```bash
# Authenticate
gcloud auth configure-docker

# Build and push Docker image
docker build -t gcr.io/<your-project-id>/excel-to-bq:latest .
docker push gcr.io/<your-project-id>/excel-to-bq:latest
```

---

### 4️⃣ Create `flex-template.json`

```json
{
  "image": "gcr.io/<your-project-id>/excel-to-bq:latest",
  "metadata": {
    "name": "excel-to-bq-pipeline",
    "description": "Loads Excel data into BigQuery",
    "parameters": [
      {
        "name": "input_gcs_path",
        "label": "GCS path to Excel file",
        "help_text": "e.g., gs://my-bucket/data/SampleData.xlsx"
      },
      {
        "name": "output_bq_table",
        "label": "BigQuery table",
        "help_text": "e.g., my-project:my_dataset.sales_data"
      }
    ]
  }
}
```

---

### 5️⃣ Stage the Flex Template

```bash
gcloud dataflow flex-template build gs://<your-bucket>/templates/excel_to_bq_template.json \
  --image gcr.io/<your-project-id>/excel-to-bq:latest \
  --sdk-language "PYTHON" \
  --metadata-file flex-template.json
```

---

### 6️⃣ Run the Template

```bash
gcloud dataflow flex-template run "excel-bq-job-$(date +%Y%m%d-%H%M%S)" \
  --template-file-gcs-location gs://<your-bucket>/templates/excel_to_bq_template.json \
  --region <your-region> \
  --parameters input_gcs_path=gs://<your-bucket>/data/SampleData.xlsx \
               output_bq_table=<your-project>:<dataset>.sales_data
```

---

## ✅ Output: BigQuery Table Populated with Excel Data 🎉

Would you like me to zip this project (Dockerfile, script, template) for easy download?

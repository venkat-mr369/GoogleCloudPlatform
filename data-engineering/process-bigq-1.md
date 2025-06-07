To **process the Excel file and load it into BigQuery using Apache Beam (Dataflow)**, follow these detailed steps.

---

## ✅ Goal: Load `SampleData.xlsx` → BigQuery using Dataflow (Beam)

---

## 🧩 Step-by-Step Guide

### 1️⃣ Upload Excel to GCS

```bash
gsutil cp SampleData.xlsx gs://<your-bucket-name>/data/SampleData.xlsx
```

---

### 2️⃣ Install Required Python Packages (for local dev)

```bash
pip install apache-beam[gcp] pandas openpyxl
```

---

### 3️⃣ Create the BigQuery Table (optional)

Let BigQuery auto-create it or pre-create with schema:

```sql
CREATE TABLE `your_project.dataset.sales_data` (
    order_date DATE,
    region STRING,
    rep STRING,
    item STRING,
    units INT64,
    unit_cost NUMERIC,
    total NUMERIC
);
```

---

### 4️⃣ Python Beam Pipeline: Excel → BigQuery

Save as `excel_to_bq.py`:

```python
import apache_beam as beam
from apache_beam.options.pipeline_options import PipelineOptions
import pandas as pd
import io

class ReadExcelFromGCS(beam.DoFn):
    def process(self, element):
        from apache_beam.io.gcp.gcsio import GcsIO

        gcs = GcsIO()
        file_data = gcs.open(element).read()
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

def run():
    options = PipelineOptions(
        runner='DataflowRunner',
        project='your-gcp-project',
        region='your-region',
        temp_location='gs://<your-bucket>/temp',
        staging_location='gs://<your-bucket>/staging',
        save_main_session=True
    )

    with beam.Pipeline(options=options) as p:
        (
            p
            | 'Start' >> beam.Create(['gs://<your-bucket>/data/SampleData.xlsx'])
            | 'Read Excel' >> beam.ParDo(ReadExcelFromGCS())
            | 'Write to BQ' >> beam.io.WriteToBigQuery(
                table='your_project:your_dataset.sales_data',
                schema='order_date:DATE,region:STRING,rep:STRING,item:STRING,units:INTEGER,unit_cost:NUMERIC,total:NUMERIC',
                write_disposition=beam.io.BigQueryDisposition.WRITE_APPEND,
                create_disposition=beam.io.BigQueryDisposition.CREATE_IF_NEEDED
            )
        )

if __name__ == '__main__':
    run()
```

---

### 5️⃣ Submit to Dataflow

```bash
python excel_to_bq.py \
  --runner DataflowRunner \
  --project your-gcp-project \
  --region your-region \
  --temp_location gs://<your-bucket>/temp \
  --staging_location gs://<your-bucket>/staging \
  --save_main_session
```

---

### ✅ Summary

| Task | Tool |
|------|------|
| Read Excel | `pandas`, `openpyxl` |
| Load to BQ | `beam.io.WriteToBigQuery` |
| Pipeline Runner | `DataflowRunner` |
| Schema | Defined manually or inferred via `dict` |

---

### 🚀 Optional Enhancements
- Use **Flex Templates** to parameterize Excel file paths
- Add **error logging** to Cloud Logging
- Add **Data Validation** steps in the pipeline

---

Would you like me to generate this pipeline as a **Dockerized Dataflow Flex Template** next?

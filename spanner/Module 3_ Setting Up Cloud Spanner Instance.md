To **set up a Cloud Spanner instance using the gcloud command**, follow these essential steps:

1. **List available instance configurations**  
   This helps you choose the correct regional, dual-region, or multi-region configuration for your needs:
   ```bash
   gcloud spanner instance-configs list
   ```
   Example output will show configurations like `regional-us-central1`, `regional-europe-west1`, etc.

2. **Run the instance creation command**  
   Use the following syntax:
   ```bash
   gcloud spanner instances create INSTANCE_ID \
     --config=INSTANCE_CONFIG \
     --description="INSTANCE_NAME" \
     --nodes=NODE_COUNT
   ```
   - `INSTANCE_ID`: Unique identifier for your instance (cannot be changed later).
   - `INSTANCE_CONFIG`: Chosen from the list in step 1 (e.g., `regional-us-central1`).
   - `INSTANCE_NAME`: Display name for the instance.
   - `NODE_COUNT`: Number of nodes (each node provides 1000 processing units).

   **Example:**
   ```bash
   gcloud spanner instances create test-instance \
     --config=regional-asia-east1 \
     --description="test-instance" \
     --nodes=1
   ```
   This command creates an instance named "Test Instance" with 1 node in the `us-central1` region.

3. **Optional: Use processing units instead of nodes**  
   For smaller instances, you can specify processing units (in multiples of 100 up to 1000, then multiples of 1000):
   ```bash
   gcloud spanner instances create test-instance \
     --config=regional-asia-east1 \
     --description="test-instance" \
     --processing-units=500
   ```
   Do not use both `--nodes` and `--processing-units` in the same command.

4. **Optional: Specify edition and backup schedule**  
   For advanced configurations, such as selecting an edition (e.g., `STANDARD`, `ENTERPRISE`, `ENTERPRISE_PLUS`) or setting a default backup schedule:
   ```bash
   gcloud spanner instances create test-instance \
     --edition=STANDARD \
     --config=regional-asia-east1 \
     --description="asia-east1" \
     --nodes=1 \
     --default-backup-schedule-type=AUTOMATIC
   ```
   - `--default-backup-schedule-type` can be `AUTOMATIC` or `NONE`.

5. **Verify the instance creation**  
   After running the command, you should see:
   ```
   Creating instance...done.
   ```
   This confirms your Cloud Spanner instance is ready for use.

**Note:**  
- You must have the Google Cloud CLI installed and authenticated before running these commands.
- Choose the configuration and node count based on your application's scalability and availability requirements.


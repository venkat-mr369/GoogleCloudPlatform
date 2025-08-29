```bash
gcloud functions deploy start-vm-function   --gen2   --runtime=python310   --region=europe-north1   --entry-point=start_vm   --trigger-event=google.cloud.pubsub.topic.v1.messagePublished   --trigger-resource=start-vm-topic   --timeout=540s   --project=rand-369
```
```bash
gcloud scheduler jobs create pubsub start-vm-job   --location=europe-north1-a   --schedule="30 1 * * *"   --topic=start-vm-topic   --message-body="Start vm01 at 7 AM IST"   --time-zone="UTC"   --project=rand-369
```

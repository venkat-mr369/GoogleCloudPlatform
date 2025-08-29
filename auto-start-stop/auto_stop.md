---main.py
```py
from googleapiclient import discovery
from google.auth import default

def stop_vm(event, context):
    credentials, project = default()

    zone = "europe-north1-a"
    instance = "vm01"

    compute = discovery.build("compute", "v1", credentials=credentials)
    request = compute.instances().stop(project=project, zone=zone, instance=instance)
    response = request.execute()

    print(f"🛑 Stopped VM {instance} in zone {zone}: {response}")
```
---requirements.txt
```py
google-api-python-client
google-auth
```

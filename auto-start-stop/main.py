from googleapiclient import discovery
from google.auth import default

def start_vm(event, context):
    # Get default credentials and project ID
    credentials, project = default()

    zone = "europe-north1-a"
    instance = "vm01"

    compute = discovery.build("compute", "v1", credentials=credentials)

    request = compute.instances().start(
        project=project,
        zone=zone,
        instance=instance
    )
    response = request.execute()

    print(f"Started VM {instance} in zone {zone}: {response}")

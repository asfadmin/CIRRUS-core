import json
import os

import boto3


def upload_cirrus_versions():
    client = boto3.client("s3")
    cirrus_core_version = os.getenv("CIRRUS_CORE_VERSION")
    cirrus_daac_version = os.getenv("CIRRUS_DAAC_VERSION")

    cirrus_versions = {
        "CIRRUS-core": cirrus_core_version,
        "CIRRUS-DAAC": cirrus_daac_version
    }

    stack = f"{os.getenv('DEPLOY_NAME')}-cumulus-{os.getenv('MATURITY')}"
    bucket = f"{stack}-internal"
    key = f"{stack}/cirrus-versions/cirrus-versions.json"

    response = client.put_object(
        Body=json.dumps(cirrus_versions),
        Bucket=bucket,
        Key=key
    )


if __name__ == "__main__":
    upload_cirrus_versions()

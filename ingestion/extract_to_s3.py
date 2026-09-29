"""Download NYC TLC yellow taxi parquet files and land them in S3 (idempotent)."""
import argparse
import os
import tempfile

import boto3
import requests
from botocore.exceptions import ClientError
from dotenv import load_dotenv

load_dotenv()
BUCKET = os.environ["S3_BUCKET"]
BASE_URL = "https://d37ci6vzurychx.cloudfront.net/trip-data/yellow_tripdata_{y}-{m:02d}.parquet"
s3 = boto3.client("s3")


def exists(key: str) -> bool:
    """Return True if the file is already in S3, so re-runs skip it."""
    try:
        s3.head_object(Bucket=BUCKET, Key=key)
        return True
    except ClientError:
        return False


def land_month(year: int, month: int) -> None:
    key = f"nyc_taxi/yellow/year={year}/month={month:02d}/yellow_tripdata_{year}-{month:02d}.parquet"
    if exists(key):
        print(f"skip  {key} (already landed)")
        return
    url = BASE_URL.format(y=year, m=month)
    print(f"get   {url}")
    with requests.get(url, stream=True, timeout=60) as r:
        r.raise_for_status()
        with tempfile.NamedTemporaryFile(suffix=".parquet") as tmp:
            for chunk in r.iter_content(chunk_size=8 * 1024 * 1024):
                tmp.write(chunk)
            tmp.flush()
            s3.upload_file(tmp.name, BUCKET, key)
    print(f"load  s3://{BUCKET}/{key}")


if __name__ == "__main__":
    p = argparse.ArgumentParser()
    p.add_argument("--year", type=int, required=True)
    p.add_argument("--months", type=int, nargs="+", default=list(range(1, 13)))
    args = p.parse_args()
    for m in args.months:
        land_month(args.year, m)
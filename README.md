# NYC Taxi ELT Pipeline on Snowflake

End-to-end data pipeline: NYC TLC trip data → Python → AWS S3 → Snowflake → dbt.

## Architecture
NYC TLC → `ingestion/extract_to_s3.py` → S3 (landing zone) → Snowflake external stage → `RAW.NYC_TAXI.YELLOW_TRIPS`

## Highlights
- Secure S3 access via Snowflake storage integration (IAM role + external ID, no stored keys)
- Least-privilege roles in Snowflake and AWS
- Idempotent ingestion: extractor skips landed files; `COPY INTO` skips loaded files
- Lineage columns (`_SOURCE_FILE`, `_LOADED_AT`) on every row
- Cost controls: XS warehouse, 60s auto-suspend, resource monitor
- 9.5M+ trips loaded (Jan–Mar 2024)

## Status
- [x] Phase 1: Ingestion (S3 → Snowflake RAW)
- [ ] Phase 2: dbt transformations (staging, star schema, tests)
- [ ] Phase 3: Orchestration + CI

USE ROLE ACCOUNTADMIN;

-- Service user for dbt, authenticated with a key pair (no password).
-- Generate keys locally, then paste the public key (no header/footer lines) below.
CREATE USER IF NOT EXISTS DBT_SVC
  TYPE = SERVICE
  DEFAULT_ROLE = TRANSFORMER
  DEFAULT_WAREHOUSE = TRANSFORM_WH
  RSA_PUBLIC_KEY = '<your_public_key>'
  COMMENT = 'Service user for dbt (key-pair auth)';

GRANT ROLE TRANSFORMER TO USER DBT_SVC;

DESC USER DBT_SVC;

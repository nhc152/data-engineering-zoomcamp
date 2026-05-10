-- Replace PROJECT_ID, RAW_DATASET, STAGING_DATASET, MARTS_DATASET before running.
-- You can also create datasets with bq CLI as shown in README.

create schema if not exists `PROJECT_ID.RAW_DATASET`
options(location = 'US');

create schema if not exists `PROJECT_ID.STAGING_DATASET`
options(location = 'US');

create schema if not exists `PROJECT_ID.MARTS_DATASET`
options(location = 'US');


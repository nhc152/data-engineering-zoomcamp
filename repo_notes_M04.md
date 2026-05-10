# repo_notes_M04.md

# 1. CẤU TRÚC THƯ MỤC

## Tree đầy đủ (04-analytics-engineering)

```text
04-analytics-engineering/
├── README.md
├── class_notes/
│   ├── 4_1_1_analytics_engineering_basics.md
│   ├── 4_1_2_what_is_dbt.md
│   ├── 4_2_1_dbt_core_vs_dbt_cloud.md
│   ├── 4_3_1_dbt_project_structure.md
│   ├── 4_3_2_dbt_sources.md
│   ├── 4_4_1_dbt_models.md
│   ├── 4_4_2_dbt_seeds_and_macros.md
│   ├── 4_5_1_documentation.md
│   ├── 4_5_2_dbt_tests.md
│   ├── 4_5_3_dbt_packages.md
│   └── 4_6_1_dbt_commands.md
├── refreshers/
│   └── SQL.md
├── setup/
│   ├── cloud_setup.md
│   ├── duckdb_troubleshooting.md
│   └── local_setup.md
└── taxi_rides_ny/
    ├── .gitignore
    ├── dbt_project.yml
    ├── package-lock.yml
    ├── packages.yml
    ├── macros/
    │   ├── get_trip_duration_minutes.sql
    │   ├── get_vendor_data.sql
    │   ├── macros_properties.yml
    │   └── safe_cast.sql
    ├── models/
    │   ├── staging/
    │   │   ├── schema.yml
    │   │   ├── sources.yml
    │   │   ├── stg_green_tripdata.sql
    │   │   └── stg_yellow_tripdata.sql
    │   ├── intermediate/
    │   │   ├── int_trips.sql
    │   │   ├── int_trips_unioned.sql
    │   │   └── schema.yml
    │   └── marts/
    │       ├── dim_vendors.sql
    │       ├── dim_zones.sql
    │       ├── fct_trips.sql
    │       ├── schema.yml
    │       └── reporting/
    │           ├── fct_monthly_zone_revenue.sql
    │           └── schema.yml
    ├── seeds/
    │   ├── payment_type_lookup.csv
    │   ├── seeds_properties.yml
    │   └── taxi_zone_lookup.csv
    ├── snapshots/
    │   └── .gitkeep
    └── tests/
        └── .gitkeep
```

## Mục đích từng folder/file

- `README.md`: entry point của Module 4, mô tả setup paths, nội dung video, homework, refresher.
- `class_notes/`: notes chi tiết theo từng bài video dbt/analytics engineering.
- `refreshers/SQL.md`: ôn lại SQL (window function, CTE) dùng cho homework/module.
- `setup/`: hướng dẫn cài đặt theo 2 nhánh Cloud (BigQuery + dbt Cloud) và Local (DuckDB + dbt Core), plus troubleshooting OOM.
- `taxi_rides_ny/`: dbt project thực hành chính.
  - `.gitignore`: ignore artifacts/local data/secrets.
  - `dbt_project.yml`: config lõi của project (profile, paths, materialization defaults, vars).
  - `packages.yml`, `package-lock.yml`: khai báo và lock dbt packages.
  - `macros/`: macro reusable/cross-database logic + macro docs.
  - `models/staging`: chuẩn hóa raw source (rename/cast/filter nhẹ).
  - `models/intermediate`: union + enrich + deduplicate trước khi vào marts.
  - `models/marts`: dimension/fact cuối cho analytics.
  - `models/marts/reporting`: reporting aggregate model.
  - `seeds/`: static lookup CSV + seed metadata/tests.
  - `snapshots/.gitkeep`: placeholder cho snapshot folder.
  - `tests/.gitkeep`: placeholder cho singular tests folder.

---

# 2. NỘI DUNG CÁC FILE .MD

## [04-analytics-engineering/README.md]
- Dạy về: tổng quan Module 4, prerequisites, 2 setup options, content map.
- Concepts chính: Analytics Engineering scope, dbt learning path, local vs cloud setup selection.
- Commands được dùng: (không có command shell cụ thể trong file này).
- Lưu ý đặc biệt: module dùng yellow+green 2019-2020; FHV không dùng trong dbt project này.

## [class_notes/4_1_1_analytics_engineering_basics.md]
- Dạy về: nền tảng Analytics Engineering, vai trò giữa DE và Analyst.
- Concepts chính: cloud DW shift, ELT dominance, analytics engineer role, dimensional modeling (fact/dim/star schema), kitchen analogy.
- Commands được dùng: (không có command cụ thể).
- Lưu ý đặc biệt: nhấn mạnh modeling theo Kimball; focus module ở modeling + presentation.

## [class_notes/4_1_2_what_is_dbt.md]
- Dạy về: dbt là gì và giải quyết vấn đề gì.
- Concepts chính: transformation workflow, ref/source/Jinja compilation, materializations, software engineering practices cho analytics.
- Commands được dùng: `dbt run`.
- Lưu ý đặc biệt: so sánh dbt Core vs Cloud; course cho 2 path BigQuery/Cloud và DuckDB/Core.

## [class_notes/4_2_1_dbt_core_vs_dbt_cloud.md]
- Dạy về: khác biệt lịch sử/chức năng giữa dbt Core và dbt Cloud, định hướng Fusion.
- Concepts chính: OSS CLI vs SaaS, hybrid usage, Fusion engine, adapter support limitations.
- Commands được dùng: (không có command cụ thể).
- Lưu ý đặc biệt: ghi rõ limitation Fusion (đầu 2026, DuckDB chưa support Fusion).

## [class_notes/4_3_1_dbt_project_structure.md]
- Dạy về: cấu trúc thư mục dbt project sau `dbt init`.
- Concepts chính: purpose của analysis/models/macros/seeds/snapshots/tests, layer staging/intermediate/marts.
- Commands được dùng: `dbt init`.
- Lưu ý đặc biệt: staging nên 1:1 với source (nguyên tắc, có thể ngoại lệ).

## [class_notes/4_3_2_dbt_sources.md]
- Dạy về: khai báo source và dùng `source()`.
- Concepts chính: sources.yml fields (database/schema/tables), local DuckDB vs BigQuery mapping, staging conventions, cast/rename.
- Commands được dùng: (gián tiếp: chạy preview/query trong IDE; không nêu câu lệnh CLI cụ thể).
- Lưu ý đặc biệt: khuyến nghị staging 1:1 nhưng chấp nhận filter `vendor_id is null` vì data quality issue.

## [class_notes/4_4_1_dbt_models.md]
- Dạy về: xây model intermediate/marts và phân biệt `source()` vs `ref()`.
- Concepts chính: star schema output, `int_` layer, dependency graph qua `ref()`, union schema alignment.
- Commands được dùng: (không có command CLI cụ thể).
- Lưu ý đặc biệt: business context taxi yellow/green ảnh hưởng logic dữ liệu (trip_type, ehail_fee).

## [class_notes/4_4_2_dbt_seeds_and_macros.md]
- Dạy về: dùng seeds và macros để enrich data.
- Concepts chính: seed lifecycle (`dbt seed`), ref seed, macro design Jinja, tránh CASE lặp.
- Commands được dùng: `dbt seed`.
- Lưu ý đặc biệt: cảnh báo không commit data nhạy cảm vào seeds (vì seeds nằm trong git).

## [class_notes/4_5_1_documentation.md]
- Dạy về: documentation trong dbt (sources/models/columns/macros/seeds).
- Concepts chính: schema.yml pattern, multi-line YAML descriptions (`|`, `>`), `meta` tags, lineage docs site.
- Commands được dùng: `dbt docs generate`, `dbt docs serve`.
- Lưu ý đặc biệt: docs site thiên về technical documentation hơn business catalog.

## [class_notes/4_5_2_dbt_tests.md]
- Dạy về: toàn bộ test types trong dbt.
- Concepts chính: singular tests, source freshness, generic tests, custom generic tests, unit tests, model contracts.
- Commands được dùng: `dbt source freshness` (đề cập), `dbt test` (context vận hành testing).
- Lưu ý đặc biệt: unit tests có từ v1.8; model contracts dùng `contract: enforced: true` để fail sớm.

## [class_notes/4_5_3_dbt_packages.md]
- Dạy về: dbt package ecosystem và cài package.
- Concepts chính: dbt-utils/codegen/project-evaluator/audit-helper/expectations, cross-db macros.
- Commands được dùng: `dbt deps`.
- Lưu ý đặc biệt: package-lock.yml cần commit để lock dependency reproducibility.

## [class_notes/4_6_1_dbt_commands.md]
- Dạy về: command landscape của dbt + selection flags.
- Concepts chính: setup commands, run/build/test/compile/retry, selectors (`--select`, `+`, `state:*`), full-refresh, target env.
- Commands được dùng: `dbt init`, `dbt debug`, `dbt deps`, `dbt clean`, `dbt seed`, `dbt snapshot`, `dbt source freshness`, `dbt docs generate`, `dbt docs serve`, `dbt compile`, `dbt run`, `dbt test`, `dbt build`, `dbt retry`, `dbt run --full-refresh`, `dbt run --target prod`, `dbt run --select ...`, `dbt build --select state:modified+ --state ./prod-artifacts`.
- Lưu ý đặc biệt: `dbt build` được nhấn mạnh là lệnh quan trọng nhất cho CI/production.

## [setup/cloud_setup.md]
- Dạy về: setup dbt Cloud kết nối BigQuery.
- Concepts chính: service account key, dataset location alignment, connection config, environment dev/deploy.
- Commands được dùng: (không có command local CLI bắt buộc; thao tác UI dbt Cloud/GCP console).
- Lưu ý đặc biệt: bắt buộc dùng data từ DataTalksClub NYC TLC release (không dùng trực tiếp official NYC TLC site để khớp homework).

## [setup/local_setup.md]
- Dạy về: setup local DuckDB + dbt Core.
- Concepts chính: install dbt-duckdb, profiles.yml, ingest script, dev/prod outputs, extension recommendation.
- Commands được dùng: `pip install dbt-duckdb`, `dbt debug`.
- Lưu ý đặc biệt: mọi dbt command chạy trong `taxi_rides_ny/`; hướng dẫn memory_limit và threads trong profile.

## [setup/duckdb_troubleshooting.md]
- Dạy về: xử lý out-of-memory khi build dbt trên DuckDB.
- Concepts chính: memory pressure points (window/union/join/hash), selective builds, retry strategy.
- Commands được dùng: `dbt retry`, `dbt build --select ... --target prod`.
- Lưu ý đặc biệt: đề xuất dùng Codespaces/Cloud path khi RAM thấp; incremental giúp nhẹ run sau.

## [refreshers/SQL.md]
- Dạy về: SQL refresher cho window functions + CTE.
- Concepts chính: ROW_NUMBER/RANK/DENSE_RANK/LAG/LEAD/PERCENTILE_CONT, CTE readability, dbt SQL style với CTE.
- Commands được dùng: SQL query examples (không có dbt CLI command).
- Lưu ý đặc biệt: có ví dụ trực tiếp liên quan taxi datasets và p90 metrics.

---

# 3. PHÂN TÍCH CODE FILES

## [dbt_project.yml]
- Project name: `taxi_rides_ny`
- Version: `1.0.0`
- Profile: `taxi_rides_ny`
- Model configs (materialization mặc định):
  - `staging`: `view`
  - `intermediate`: `table`
  - `marts`: `table`
- Vars:
  - `dev_start_date: '2019-01-01'`
  - `dev_end_date: '2019-02-01'`

**Copy nguyên văn (`taxi_rides_ny/dbt_project.yml`):**
```yaml
name: 'taxi_rides_ny'
version: '1.0.0'

# Require a specific dbt version for reproducibility
require-dbt-version: [">=1.7.0", "<3.0.0"]

# This setting configures which "profile" dbt uses for this project.
profile: 'taxi_rides_ny'

# These configurations specify where dbt should look for different types of files.
model-paths: ["models"]
analysis-paths: ["analyses"]
test-paths: ["tests"]
seed-paths: ["seeds"]
macro-paths: ["macros"]
snapshot-paths: ["snapshots"]

clean-targets:
  - "target"
  - "dbt_packages"

# Project-level variables
vars:
  # Date range for dev environment sampling
  dev_start_date: '2019-01-01'
  dev_end_date: '2019-02-01'

# Configuring models
# Full documentation: https://docs.getdbt.com/docs/configuring-models
models:
  taxi_rides_ny:
    staging:
      +materialized: view
    intermediate:
      +materialized: table
    marts:
      +materialized: table
flags:
  require_generic_test_arguments_property: true
```

## [packages.yml / package-lock.yml]
- Packages:
  - `dbt-labs/dbt_utils` (range ở packages.yml; resolved lock: `1.3.3`)
  - `dbt-labs/codegen` (range ở packages.yml; resolved lock: `0.14.0`)
- Có lock hash trong `package-lock.yml`.

**Copy nguyên văn (`taxi_rides_ny/packages.yml`):**
```yaml
packages:
  - package: dbt-labs/dbt_utils
    version: [">=1.3.0", "<2.0.0"]
  - package: dbt-labs/codegen
    version: [">=0.14.0", "<1.0.0"]
```

**Copy nguyên văn (`taxi_rides_ny/package-lock.yml`):**
```yaml
packages:
  - name: dbt_utils
    package: dbt-labs/dbt_utils
    version: 1.3.3
  - name: codegen
    package: dbt-labs/codegen
    version: 0.14.0
sha1_hash: 01f31e0d658d76121f50e62b998342ebf138df11
```

## [sources.yml]
- Sources khai báo:
  - source name: `raw`
  - database:
    - BigQuery: lấy từ `env_var('GCP_PROJECT_ID', ...)`
    - non-BigQuery: `taxi_rides_ny`
  - schema:
    - BigQuery: `nytaxi`
    - non-BigQuery: `prod`
  - tables:
    - `green_tripdata`
    - `yellow_tripdata`
- Freshness config:
  - `warn_after: 24h`
  - `error_after: 48h`

**Copy nguyên văn (`taxi_rides_ny/models/staging/sources.yml`):**
```yaml
sources:
  - name: raw
    description: Raw taxi trip data from NYC TLC
    database: |
      {%- if target.type == 'bigquery' -%}
        {{ env_var('GCP_PROJECT_ID', 'please-add-your-gcp-project-id-here') }}
      {%- else -%}
        taxi_rides_ny
      {%- endif -%}
    schema: |
      {%- if target.type == 'bigquery' -%}
        nytaxi
      {%- else -%}
        prod
      {%- endif -%}
    tables:
      - name: green_tripdata
        description: Raw green taxi trip records
        columns:
          - name: vendorid
            description: "Taxi technology provider (1 = Creative Mobile Technologies, 2 = VeriFone Inc.) - Note: Raw data may contain nulls, filtered in staging"
          - name: lpep_pickup_datetime
            description: Date and time when the meter was engaged
          - name: lpep_dropoff_datetime
            description: Date and time when the meter was disengaged
          - name: passenger_count
            description: Number of passengers in the vehicle
          - name: trip_distance
            description: Trip distance in miles
          - name: pulocationid
            description: TLC Taxi Zone where the meter was engaged
          - name: dolocationid
            description: TLC Taxi Zone where the meter was disengaged
          - name: ratecodeid
            description: Rate code (1=Standard, 2=JFK, 3=Newark, 4=Nassau/Westchester, 5=Negotiated, 6=Group)
          - name: store_and_fwd_flag
            description: Trip record held in vehicle memory (Y/N)
          - name: payment_type
            description: Payment method (1=Credit card, 2=Cash, 3=No charge, 4=Dispute, 5=Unknown, 6=Voided)
          - name: fare_amount
            description: Time and distance fare
          - name: extra
            description: Miscellaneous extras and surcharges
          - name: mta_tax
            description: MTA tax
          - name: tip_amount
            description: Tip amount (credit card only)
          - name: tolls_amount
            description: Total tolls paid
          - name: improvement_surcharge
            description: Improvement surcharge
          - name: total_amount
            description: Total amount charged
          - name: trip_type
            description: Trip type (1=Street-hail, 2=Dispatch)
          - name: ehail_fee
            description: E-hail fee

        config:
          loaded_at_field: lpep_pickup_datetime
      - name: yellow_tripdata
        description: Raw yellow taxi trip records
        columns:
          - name: vendorid
            description: "Taxi technology provider (1 = Creative Mobile Technologies, 2 = VeriFone Inc.) - Note: Raw data may contain nulls, filtered in staging"
          - name: tpep_pickup_datetime
            description: Date and time when the meter was engaged
          - name: tpep_dropoff_datetime
            description: Date and time when the meter was disengaged
          - name: passenger_count
            description: Number of passengers in the vehicle
          - name: trip_distance
            description: Trip distance in miles
          - name: pulocationid
            description: TLC Taxi Zone where the meter was engaged
          - name: dolocationid
            description: TLC Taxi Zone where the meter was disengaged
          - name: ratecodeid
            description: Rate code (1=Standard, 2=JFK, 3=Newark, 4=Nassau/Westchester, 5=Negotiated, 6=Group)
          - name: store_and_fwd_flag
            description: Trip record held in vehicle memory (Y/N)
          - name: payment_type
            description: Payment method (1=Credit card, 2=Cash, 3=No charge, 4=Dispute, 5=Unknown, 6=Voided)
          - name: fare_amount
            description: Time and distance fare
          - name: extra
            description: Miscellaneous extras and surcharges
          - name: mta_tax
            description: MTA tax
          - name: tip_amount
            description: Tip amount (credit card only)
          - name: tolls_amount
            description: Total tolls paid
          - name: improvement_surcharge
            description: Improvement surcharge
          - name: total_amount
            description: Total amount charged
        config:
          loaded_at_field: tpep_pickup_datetime
    config:
      freshness:
        warn_after: {count: 24, period: hour}
        error_after: {count: 48, period: hour}
```

## [schema.yml - từng layer]

### A) Staging schema
- Models document:
  - `stg_green_tripdata`
  - `stg_yellow_tripdata`
- Tests:
  - `vendor_id`: `not_null` (cả 2 model)
  - `pickup_datetime`: `not_null` (cả 2 model)

**Copy nguyên văn (`taxi_rides_ny/models/staging/schema.yml`):**
```yaml
models:
  - name: stg_green_tripdata
    description: >
      Staging model for green taxi trip data. This model standardizes column names
      and data types from the raw green_tripdata source, providing a clean foundation
      for downstream transformations.
    columns:
      - name: vendor_id
        description: Taxi technology provider (1 = Creative Mobile Technologies, 2 = VeriFone Inc.)
        data_tests:
          - not_null
      - name: rate_code_id
        description: Rate code at end of trip (1=Standard, 2=JFK, 3=Newark, 4=Nassau/Westchester, 5=Negotiated, 6=Group)
      - name: pickup_location_id
        description: TLC Taxi Zone where the meter was engaged
      - name: dropoff_location_id
        description: TLC Taxi Zone where the meter was disengaged
      - name: pickup_datetime
        description: Date and time when the meter was engaged
        data_tests:
          - not_null
      - name: dropoff_datetime
        description: Date and time when the meter was disengaged
      - name: store_and_fwd_flag
        description: Flag indicating if trip record was held in vehicle memory (Y/N)
      - name: passenger_count
        description: Number of passengers in the vehicle (driver-entered value)
      - name: trip_distance
        description: Trip distance in miles reported by the taximeter
      - name: trip_type
        description: Code for trip type (1=Street-hail, 2=Dispatch)
      - name: fare_amount
        description: Time and distance fare calculated by the meter
      - name: extra
        description: Miscellaneous extras and surcharges (rush hour, overnight)
      - name: mta_tax
        description: $0.50 MTA tax automatically triggered based on meter rate
      - name: tip_amount
        description: Tip amount (credit card tips only, cash tips not included)
      - name: tolls_amount
        description: Total amount of all tolls paid during the trip
      - name: ehail_fee
        description: E-hail service fee
      - name: improvement_surcharge
        description: Improvement surcharge assessed on hailed trips
      - name: total_amount
        description: Total amount charged to passengers (does not include cash tips)
      - name: payment_type
        description: Payment method code (1=Credit card, 2=Cash, 3=No charge, 4=Dispute, 5=Unknown, 6=Voided)

  - name: stg_yellow_tripdata
    description: >
      Staging model for yellow taxi trip data. This model standardizes column names
      and data types from the raw yellow_tripdata source, providing a clean foundation
      for downstream transformations.
    columns:
      - name: vendor_id
        description: Taxi technology provider (1 = Creative Mobile Technologies, 2 = VeriFone Inc.)
        data_tests:
          - not_null
      - name: rate_code_id
        description: Rate code at end of trip (1=Standard, 2=JFK, 3=Newark, 4=Nassau/Westchester, 5=Negotiated, 6=Group)
      - name: pickup_location_id
        description: TLC Taxi Zone where the meter was engaged
      - name: dropoff_location_id
        description: TLC Taxi Zone where the meter was disengaged
      - name: pickup_datetime
        description: Date and time when the meter was engaged
        data_tests:
          - not_null
      - name: dropoff_datetime
        description: Date and time when the meter was disengaged
      - name: store_and_fwd_flag
        description: Flag indicating if trip record was held in vehicle memory (Y/N)
      - name: passenger_count
        description: Number of passengers in the vehicle (driver-entered value)
      - name: trip_distance
        description: Trip distance in miles reported by the taximeter
      - name: fare_amount
        description: Time and distance fare calculated by the meter
      - name: extra
        description: Miscellaneous extras and surcharges (rush hour, overnight)
      - name: mta_tax
        description: $0.50 MTA tax automatically triggered based on meter rate
      - name: tip_amount
        description: Tip amount (credit card tips only, cash tips not included)
      - name: tolls_amount
        description: Total amount of all tolls paid during the trip
      - name: improvement_surcharge
        description: Improvement surcharge assessed on hailed trips
      - name: total_amount
        description: Total amount charged to passengers (does not include cash tips)
      - name: payment_type
        description: Payment method code (1=Credit card, 2=Cash, 3=No charge, 4=Dispute, 5=Unknown, 6=Voided)
```

### B) Intermediate schema
- Models document:
  - `int_trips_unioned`
  - `int_trips`
- Tests:
  - `int_trips.trip_id`: `unique`, `not_null`
  - `int_trips.vendor_id`: `not_null`
  - `int_trips.service_type`: `not_null`, `accepted_values=['Green','Yellow']`
  - `int_trips.pickup_datetime`: `not_null`
  - `int_trips.total_amount`: `not_null`

**Copy nguyên văn (`taxi_rides_ny/models/intermediate/schema.yml`):**
```yaml
models:
  - name: int_trips_unioned
    description: Union of green and yellow taxi trip data with normalized schema
    columns:
      - name: vendor_id
        description: Taxi technology provider ID
      - name: rate_code_id
        description: Rate code at end of trip (1=Standard, 2=JFK, 3=Newark, 4=Nassau/Westchester, 5=Negotiated, 6=Group)
      - name: pickup_location_id
        description: TLC Taxi Zone where trip started
      - name: dropoff_location_id
        description: TLC Taxi Zone where trip ended
      - name: pickup_datetime
        description: Timestamp when meter was engaged
      - name: dropoff_datetime
        description: Timestamp when meter was disengaged
      - name: store_and_fwd_flag
        description: Trip record stored in vehicle memory (Y/N)
      - name: passenger_count
        description: Number of passengers in the vehicle
      - name: trip_distance
        description: Trip distance in miles
      - name: trip_type
        description: Trip type (1=Street-hail, 2=Dispatch)
      - name: fare_amount
        description: Time and distance fare
      - name: extra
        description: Miscellaneous extras and surcharges
      - name: mta_tax
        description: MTA tax
      - name: tip_amount
        description: Tip amount (credit card only)
      - name: tolls_amount
        description: Total tolls paid
      - name: ehail_fee
        description: E-hail service fee
      - name: improvement_surcharge
        description: Improvement surcharge
      - name: total_amount
        description: Total amount charged to passenger
      - name: payment_type
        description: Payment method code
      - name: service_type
        description: Type of taxi service (Green or Yellow)

  - name: int_trips
    description: Cleaned, enriched, and deduplicated trip data ready for marts
    columns:
      - name: trip_id
        description: Unique trip identifier (surrogate key)
        data_tests:
          - unique
          - not_null
      - name: vendor_id
        description: Taxi technology provider ID
        data_tests:
          - not_null
      - name: service_type
        description: Type of taxi service (Green or Yellow)
        data_tests:
          - not_null
          - accepted_values:
              arguments:
                values: ['Green', 'Yellow']
      - name: rate_code_id
        description: Rate code at end of trip
      - name: pickup_location_id
        description: TLC Taxi Zone where trip started
      - name: dropoff_location_id
        description: TLC Taxi Zone where trip ended
      - name: pickup_datetime
        description: Timestamp when meter was engaged
        data_tests:
          - not_null
      - name: dropoff_datetime
        description: Timestamp when meter was disengaged
      - name: store_and_fwd_flag
        description: Trip record stored in vehicle memory (Y/N)
      - name: passenger_count
        description: Number of passengers in the vehicle
      - name: trip_distance
        description: Trip distance in miles
      - name: trip_type
        description: Trip type (1=Street-hail, 2=Dispatch)
      - name: fare_amount
        description: Time and distance fare
      - name: extra
        description: Miscellaneous extras and surcharges
      - name: mta_tax
        description: MTA tax
      - name: tip_amount
        description: Tip amount (credit card only)
      - name: tolls_amount
        description: Total tolls paid
      - name: ehail_fee
        description: E-hail service fee
      - name: improvement_surcharge
        description: Improvement surcharge
      - name: total_amount
        description: Total amount charged to passenger
        data_tests:
          - not_null
      - name: payment_type
        description: Payment method code
      - name: payment_type_description
        description: Human-readable payment method description
```

### C) Marts schema
- Models document:
  - `dim_zones`, `dim_vendors`, `fct_trips`
- Tests:
  - `dim_zones.location_id`: `unique`, `not_null`
  - `dim_vendors.vendor_id`: `unique`, `not_null`
  - `fct_trips.trip_id`: `unique`, `not_null`
  - `fct_trips.service_type`: `accepted_values`, `not_null`
  - relationships:
    - `pickup_location_id -> dim_zones.location_id`
    - `dropoff_location_id -> dim_zones.location_id`
  - `fct_trips.pickup_datetime`: `not_null`
  - `fct_trips.total_amount`: `not_null`
- Contract: `fct_trips` bật `contract.enforced=true`.

**Copy nguyên văn (`taxi_rides_ny/models/marts/schema.yml`):**
```yaml
models:
  - name: dim_zones
    description: Taxi zone dimension table with location details
    columns:
      - name: location_id
        description: Unique identifier for each taxi zone
        data_tests:
          - unique
          - not_null
      - name: borough
        description: NYC borough name
      - name: zone
        description: Specific zone name within the borough
      - name: service_zone
        description: Service zone classification

  - name: dim_vendors
    description: Taxi technology vendor dimension table
    columns:
      - name: vendor_id
        description: Unique vendor identifier
        data_tests:
          - unique
          - not_null
      - name: vendor_name
        description: Company name of the vendor

  - name: fct_trips
    description: Fact table with all taxi trips including trip and payment details
    config:
      contract:
        enforced: true
    columns:
      - name: trip_id
        description: Unique trip identifier
        data_type: string
        data_tests:
          - unique
          - not_null
      - name: vendor_id
        description: Taxi technology provider
        data_type: integer
        data_tests:
          - not_null
      - name: service_type
        description: Type of taxi service (Green or Yellow)
        data_type: string
        data_tests:
          - accepted_values:
              arguments:
                values: ['Green', 'Yellow']
          - not_null
      - name: rate_code_id
        description: Final rate code
        data_type: integer
      - name: pickup_location_id
        description: TLC Taxi Zone where trip started
        data_type: integer
        data_tests:
          - relationships:
              arguments:
                to: ref('dim_zones')
                field: location_id
      - name: pickup_borough
        description: NYC borough where trip started
        data_type: string
      - name: pickup_zone
        description: Specific zone where trip started
        data_type: string
      - name: dropoff_location_id
        description: TLC Taxi Zone where trip ended
        data_type: integer
        data_tests:
          - relationships:
              arguments:
                to: ref('dim_zones')
                field: location_id
      - name: dropoff_borough
        description: NYC borough where trip ended
        data_type: string
      - name: dropoff_zone
        description: Specific zone where trip ended
        data_type: string
      - name: pickup_datetime
        description: Timestamp when meter was engaged
        data_type: timestamp
        data_tests:
          - not_null
      - name: dropoff_datetime
        description: Timestamp when meter was disengaged
        data_type: timestamp
      - name: store_and_fwd_flag
        description: Trip record stored in vehicle memory (Y/N)
        data_type: string
      - name: passenger_count
        description: Number of passengers
        data_type: integer
      - name: trip_distance
        description: Trip distance in miles
        data_type: numeric
      - name: trip_type
        description: Trip type (1=Street-hail, 2=Dispatch)
        data_type: integer
      - name: trip_duration_minutes
        description: Trip duration in minutes (calculated using cross-database macro)
        data_type: bigint
      - name: fare_amount
        description: Time and distance fare
        data_type: numeric
      - name: extra
        description: Miscellaneous extras and surcharges
        data_type: numeric
      - name: mta_tax
        description: MTA tax
        data_type: numeric
      - name: tip_amount
        description: Tip amount (credit card only)
        data_type: numeric
      - name: tolls_amount
        description: Total tolls paid
        data_type: numeric
      - name: ehail_fee
        description: E-hail service fee
        data_type: numeric
      - name: improvement_surcharge
        description: Improvement surcharge
        data_type: numeric
      - name: total_amount
        description: Total amount charged
        data_type: numeric
        data_tests:
          - not_null
      - name: payment_type
        description: Payment method code
        data_type: integer
      - name: payment_type_description
        description: Human-readable payment method description
        data_type: string
```

### D) Reporting schema
- Models document:
  - `fct_monthly_zone_revenue`
- Tests:
  - model-level: `dbt_utils.unique_combination_of_columns` trên `pickup_zone + revenue_month + service_type`
  - column-level: `not_null` cho pickup_zone, revenue_month, service_type, revenue_monthly_total_amount, total_monthly_trips
  - accepted values cho service_type.

**Copy nguyên văn (`taxi_rides_ny/models/marts/reporting/schema.yml`):**
```yaml
models:
  - name: fct_monthly_zone_revenue
    description: Monthly revenue aggregation by pickup zone and service type for business reporting
    data_tests:
      - dbt_utils.unique_combination_of_columns:
          arguments:
            combination_of_columns:
              - pickup_zone
              - revenue_month
              - service_type
    columns:
      - name: pickup_zone
        description: Pickup zone where revenue was generated
        data_tests:
          - not_null
      - name: revenue_month
        description: Month for revenue aggregation
        data_tests:
          - not_null
      - name: service_type
        description: Service type (Green or Yellow)
        data_tests:
          - not_null
          - accepted_values:
              arguments:
                values: ['Green', 'Yellow']
      - name: revenue_monthly_total_amount
        description: Monthly sum of total fares
        data_tests:
          - not_null
      - name: total_monthly_trips
        description: Count of trips in the month
        data_tests:
          - not_null
```

## [macros_properties.yml]
- Macros khai báo:
  - `get_trip_duration_minutes(pickup_datetime, dropoff_datetime)`
  - `get_vendor_data(vendor_id_column)`
- Có mô tả arguments và semantics.

**Copy nguyên văn (`taxi_rides_ny/macros/macros_properties.yml`):**
```yaml
macros:
  - name: get_trip_duration_minutes
    description: >
      Calculates trip duration in minutes from pickup and dropoff timestamps.
      This macro is cross-database compatible, supporting both DuckDB and BigQuery.
      Returns a numeric value representing the duration in minutes.
    arguments:
      - name: pickup_datetime
        type: timestamp
        description: The pickup timestamp
      - name: dropoff_datetime
        type: timestamp
        description: The dropoff timestamp

  - name: get_vendor_data
    description: >
      Generates a CASE statement that maps vendor_id to vendor_name.
      This macro is cross-database compatible and generates SQL at compile time using a Jinja dictionary.
      Supports vendor IDs: 1 (Creative Mobile Technologies), 2 (VeriFone Inc.), 4 (Unknown/Other).
    arguments:
      - name: vendor_id_column
        type: integer
        description: The column name containing the vendor ID
```

## [seeds_properties.yml]
- Seeds khai báo:
  - `taxi_zone_lookup`
  - `payment_type_lookup`
- Column tests:
  - `payment_type_lookup.payment_type`: `unique`, `not_null`

**Copy nguyên văn (`taxi_rides_ny/seeds/seeds_properties.yml`):**
```yaml
seeds:
  - name: taxi_zone_lookup
    description: >
      Taxi Zones roughly based on NYC Department of City Planning's Neighborhood
      Tabulation Areas (NTAs) and are meant to approximate neighborhoods, so you can see which
      neighborhood a passenger was picked up in, and which neighborhood they were dropped off in.
      Includes associated service_zone (EWR, Boro Zone, Yellow Zone)

  - name: payment_type_lookup
    description: >
      Payment type reference data mapping payment type codes to their descriptions.
      Used as a dimension table for payment method analysis.
    columns:
      - name: payment_type
        description: Numeric code for payment type
        data_tests:
          - unique
          - not_null
      - name: description
        description: Human-readable description of payment method
```

## [Từng file .sql trong macros/]

### `taxi_rides_ny/macros/get_vendor_data.sql`
- Macro name: `get_vendor_data`
- Arguments: `vendor_id_column`
- Logic chính: dựng CASE statement compile-time từ Jinja dictionary map vendor_id -> vendor_name.

**Copy nguyên văn:**
```sql
{#
    Macro to generate vendor_name column using Jinja dictionary.

    This approach works seamlessly across BigQuery, DuckDB, Snowflake, etc.
    by generating a CASE statement at compile time.

    Usage: {{ get_vendor_data('vendor_id') }}
    Returns: SQL CASE expression that maps vendor_id to vendor_name
#}

{% macro get_vendor_data(vendor_id_column) %}

{% set vendors = {
    1: 'Creative Mobile Technologies',
    2: 'VeriFone Inc.',
    4: 'Unknown/Other'
} %}

case {{ vendor_id_column }}
    {% for vendor_id, vendor_name in vendors.items() %}
    when {{ vendor_id }} then '{{ vendor_name }}'
    {% endfor %}
end

{% endmacro %}
```

### `taxi_rides_ny/macros/get_trip_duration_minutes.sql`
- Macro name: `get_trip_duration_minutes`
- Arguments: `pickup_datetime`, `dropoff_datetime`
- Logic chính: dùng `dbt.datediff(..., 'minute')` cross-database để tính duration minutes.

**Copy nguyên văn:**
```sql
{#
    Calculate trip duration in minutes from pickup and dropoff timestamps.

    Uses dbts built-in cross-database datediff macro.
    This works seamlessly across DuckDB, BigQuery, Snowflake, Redshift, PostgreSQL, etc.

    Returns: Trip duration as a numeric value in minutes
#}

{% macro get_trip_duration_minutes(pickup_datetime, dropoff_datetime) %}
    {{ dbt.datediff(pickup_datetime, dropoff_datetime, 'minute') }}
{% endmacro %}
```

### `taxi_rides_ny/macros/safe_cast.sql`
- Macro name: `safe_cast`
- Arguments: `column`, `data_type`
- Logic chính: BigQuery dùng `safe_cast`, adapter khác dùng `cast` thường.

**Copy nguyên văn:**
```sql
{% macro safe_cast(column, data_type) %}
    {% if target.type == 'bigquery' %}
        safe_cast({{ column }} as {{ data_type }})
    {% else %}
        cast({{ column }} as {{ data_type }})
    {% endif %}
{% endmacro %}
```

## [Từng file .sql trong models/staging/]

### `taxi_rides_ny/models/staging/stg_green_tripdata.sql`
- Source ref: `{{ source('raw', 'green_tripdata') }}`
- Transformations:
  - rename chuẩn snake_case business names
  - cast types
  - `safe_cast` cho `ratecodeid`, `trip_type`, `payment_type`
  - filter `vendorid is not null`
  - dev sampling theo date range (2019-01-01 to 2019-02-01)
- Materialization: `view` (default từ `dbt_project.yml` cho `staging`).

**Copy nguyên văn:**
```sql
with source as (
    select * from {{ source('raw', 'green_tripdata') }}
),

renamed as (
    select
        -- identifiers
        cast(vendorid as integer) as vendor_id,
        {{ safe_cast('ratecodeid', 'integer') }} as rate_code_id,
        cast(pulocationid as integer) as pickup_location_id,
        cast(dolocationid as integer) as dropoff_location_id,

        -- timestamps
        cast(lpep_pickup_datetime as timestamp) as pickup_datetime,  -- lpep = Licensed Passenger Enhancement Program (green taxis)
        cast(lpep_dropoff_datetime as timestamp) as dropoff_datetime,

        -- trip info
        cast(store_and_fwd_flag as string) as store_and_fwd_flag,
        cast(passenger_count as integer) as passenger_count,
        cast(trip_distance as numeric) as trip_distance,
        {{ safe_cast('trip_type', 'integer') }} as trip_type,

        -- payment info
        cast(fare_amount as numeric) as fare_amount,
        cast(extra as numeric) as extra,
        cast(mta_tax as numeric) as mta_tax,
        cast(tip_amount as numeric) as tip_amount,
        cast(tolls_amount as numeric) as tolls_amount,
        cast(ehail_fee as numeric) as ehail_fee,
        cast(improvement_surcharge as numeric) as improvement_surcharge,
        cast(total_amount as numeric) as total_amount,
        {{ safe_cast('payment_type', 'integer') }} as payment_type
    from source
    -- Filter out records with null vendor_id (data quality requirement)
    where vendorid is not null
)

select * from renamed

-- Sample records for dev environment using deterministic date filter
{% if target.name == 'dev' %}
where pickup_datetime >= '2019-01-01' and pickup_datetime < '2019-02-01'
{% endif %}
```

### `taxi_rides_ny/models/staging/stg_yellow_tripdata.sql`
- Source ref: `{{ source('raw', 'yellow_tripdata') }}`
- Transformations:
  - rename chuẩn snake_case tương thích green schema
  - cast types
  - filter `vendorid is not null`
  - dev sampling theo date range
- Materialization: `view`.

**Copy nguyên văn:**
```sql
with source as (
    select * from {{ source('raw', 'yellow_tripdata') }}
),

renamed as (
    select
        -- identifiers (standardized naming for consistency across yellow/green)
        cast(vendorid as integer) as vendor_id,
        cast(ratecodeid as integer) as rate_code_id,
        cast(pulocationid as integer) as pickup_location_id,
        cast(dolocationid as integer) as dropoff_location_id,

        -- timestamps (standardized naming)
        cast(tpep_pickup_datetime as timestamp) as pickup_datetime,  -- tpep = Taxicab Passenger Enhancement Program (yellow taxis)
        cast(tpep_dropoff_datetime as timestamp) as dropoff_datetime,

        -- trip info
        cast(store_and_fwd_flag as string) as store_and_fwd_flag,
        cast(passenger_count as integer) as passenger_count,
        cast(trip_distance as numeric) as trip_distance,

        -- payment info
        cast(fare_amount as numeric) as fare_amount,
        cast(extra as numeric) as extra,
        cast(mta_tax as numeric) as mta_tax,
        cast(tip_amount as numeric) as tip_amount,
        cast(tolls_amount as numeric) as tolls_amount,
        cast(improvement_surcharge as numeric) as improvement_surcharge,
        cast(total_amount as numeric) as total_amount,
        cast(payment_type as integer) as payment_type

    from source
    -- Filter out records with null vendor_id (data quality requirement)
    where vendorid is not null
)

select * from renamed

-- Sample records for dev environment using deterministic date filter
{% if target.name == 'dev' %}
where pickup_datetime >= '2019-01-01' and pickup_datetime < '2019-02-01'
{% endif %}
```

## [Từng file .sql trong models/intermediate/]

### `taxi_rides_ny/models/intermediate/int_trips_unioned.sql`
- Model refs:
  - `{{ ref('stg_green_tripdata') }}`
  - `{{ ref('stg_yellow_tripdata') }}`
- Transformations:
  - chuẩn hóa yellow để match green (`trip_type=1`, `ehail_fee=0`)
  - thêm `service_type` (`Green`/`Yellow`)
  - union all 2 nguồn.
- Materialization: `table` (default intermediate).

**Copy nguyên văn:**
```sql
-- Union green and yellow taxi data into a single dataset
-- Demonstrates how to combine data from multiple sources with slightly different schemas

with green_trips as (
    select
        vendor_id,
        rate_code_id,
        pickup_location_id,
        dropoff_location_id,
        pickup_datetime,
        dropoff_datetime,
        store_and_fwd_flag,
        passenger_count,
        trip_distance,
        trip_type,
        fare_amount,
        extra,
        mta_tax,
        tip_amount,
        tolls_amount,
        ehail_fee,
        improvement_surcharge,
        total_amount,
        payment_type,
        'Green' as service_type
    from {{ ref('stg_green_tripdata') }}
),

yellow_trips as (
    select
        vendor_id,
        rate_code_id,
        pickup_location_id,
        dropoff_location_id,
        pickup_datetime,
        dropoff_datetime,
        store_and_fwd_flag,
        passenger_count,
        trip_distance,
        cast(1 as integer) as trip_type,  -- Yellow taxis only do street-hail (code 1)
        fare_amount,
        extra,
        mta_tax,
        tip_amount,
        tolls_amount,
        cast(0 as numeric) as ehail_fee,  -- Yellow taxis don't have ehail_fee
        improvement_surcharge,
        total_amount,
        payment_type,
        'Yellow' as service_type
    from {{ ref('stg_yellow_tripdata') }}
)

select * from green_trips
union all
select * from yellow_trips
```

### `taxi_rides_ny/models/intermediate/int_trips.sql`
- Model refs:
  - `{{ ref('int_trips_unioned') }}`
  - `{{ ref('payment_type_lookup') }}` (seed)
- Transformations:
  - generate `trip_id` qua `dbt_utils.generate_surrogate_key`
  - enrich payment type description (left join seed)
  - coalesce payment_type/description default unknown
  - deduplicate qua `qualify row_number()...=1`.
- Materialization: `table`.

**Copy nguyên văn:**
```sql
-- Enrich and deduplicate trip data
-- Demonstrates enrichment and surrogate key generation
-- Note: Data quality analysis available in analyses/trips_data_quality.sql

with unioned as (
    select * from {{ ref('int_trips_unioned') }}
),

payment_types as (
    select * from {{ ref('payment_type_lookup') }}
),

cleaned_and_enriched as (
    select
        -- Generate unique trip identifier (surrogate key pattern)
        {{ dbt_utils.generate_surrogate_key(['u.vendor_id', 'u.pickup_datetime', 'u.pickup_location_id', 'u.service_type']) }} as trip_id,

        -- Identifiers
        u.vendor_id,
        u.service_type,
        u.rate_code_id,

        -- Location IDs
        u.pickup_location_id,
        u.dropoff_location_id,

        -- Timestamps
        u.pickup_datetime,
        u.dropoff_datetime,

        -- Trip details
        u.store_and_fwd_flag,
        u.passenger_count,
        u.trip_distance,
        u.trip_type,

        -- Payment breakdown
        u.fare_amount,
        u.extra,
        u.mta_tax,
        u.tip_amount,
        u.tolls_amount,
        u.ehail_fee,
        u.improvement_surcharge,
        u.total_amount,

        -- Enrich with payment type description
        coalesce(u.payment_type, 0) as payment_type,
        coalesce(pt.description, 'Unknown') as payment_type_description

    from unioned u
    left join payment_types pt
        on coalesce(u.payment_type, 0) = pt.payment_type
)

select * from cleaned_and_enriched

-- Deduplicate: if multiple trips match (same vendor, second, location, service), keep first
qualify row_number() over(
    partition by vendor_id, pickup_datetime, pickup_location_id, service_type
    order by dropoff_datetime
) = 1
```

## [Từng file .sql trong models/marts/]

### `taxi_rides_ny/models/marts/dim_zones.sql`
- Models được ref: `{{ ref('taxi_zone_lookup') }}` (seed)
- Business logic: dimension hóa lookup zones (rename `locationid -> location_id`).
- Materialization: `table` (default marts).

**Copy nguyên văn:**
```sql
-- Dimension table for NYC taxi zones
-- This is a simple pass-through from the seed file, but having it as a model
-- allows for future enhancements (e.g., adding calculated fields, filtering)

select
    locationid as location_id,
    borough,
    zone,
    service_zone
from {{ ref('taxi_zone_lookup') }}
```

### `taxi_rides_ny/models/marts/dim_vendors.sql`
- Models được ref: `{{ ref('fct_trips') }}`
- Business logic: lấy distinct vendor_id từ facts, map sang vendor_name qua macro `get_vendor_data`.
- Materialization: `table`.

**Copy nguyên văn:**
```sql
-- Dimension table for taxi technology vendors
-- Small static dimension defining vendor codes and their company names

with trips as (
    select * from {{ ref('fct_trips') }}
),

vendors as (
    select distinct
        vendor_id,
        {{ get_vendor_data('vendor_id') }} as vendor_name
    from trips
)

select * from vendors
```

### `taxi_rides_ny/models/marts/fct_trips.sql`
- Models được ref:
  - `{{ ref('int_trips') }}`
  - `{{ ref('dim_zones') }}` (2 lần join pickup/dropoff)
- Business logic:
  - fact table trip-level
  - enrich borough/zone
  - compute `trip_duration_minutes` qua macro
  - incremental merge với `unique_key=trip_id`
  - incremental filter theo max pickup_datetime đã tồn tại.
- Materialization: **incremental** (override default marts table).

**Copy nguyên văn:**
```sql
{{
  config(
    materialized='incremental',
    unique_key='trip_id',
    incremental_strategy='merge',
    on_schema_change='append_new_columns'  )
}}

-- Fact table containing all taxi trips enriched with zone information
-- This is a classic star schema design: fact table (trips) joined to dimension table (zones)
-- Materialized incrementally to handle large datasets efficiently

select
    -- Trip identifiers
    trips.trip_id,
    trips.vendor_id,
    trips.service_type,
    trips.rate_code_id,

    -- Location details (enriched with human-readable zone names from dimension)
    trips.pickup_location_id,
    pz.borough as pickup_borough,
    pz.zone as pickup_zone,
    trips.dropoff_location_id,
    dz.borough as dropoff_borough,
    dz.zone as dropoff_zone,

    -- Trip timing
    trips.pickup_datetime,
    trips.dropoff_datetime,
    trips.store_and_fwd_flag,

    -- Trip metrics
    trips.passenger_count,
    trips.trip_distance,
    trips.trip_type,
    {{ get_trip_duration_minutes('trips.pickup_datetime', 'trips.dropoff_datetime') }} as trip_duration_minutes,

    -- Payment breakdown
    trips.fare_amount,
    trips.extra,
    trips.mta_tax,
    trips.tip_amount,
    trips.tolls_amount,
    trips.ehail_fee,
    trips.improvement_surcharge,
    trips.total_amount,
    trips.payment_type,
    trips.payment_type_description

from {{ ref('int_trips') }} as trips
-- LEFT JOIN preserves all trips even if zone information is missing or unknown
left join {{ ref('dim_zones') }} as pz
    on trips.pickup_location_id = pz.location_id
left join {{ ref('dim_zones') }} as dz
    on trips.dropoff_location_id = dz.location_id

{% if is_incremental() %}
  -- Only process new trips based on pickup datetime
  where trips.pickup_datetime > (select max(pickup_datetime) from {{ this }})
{% endif %}
```

### `taxi_rides_ny/models/marts/reporting/fct_monthly_zone_revenue.sql`
- Models được ref: `{{ ref('fct_trips') }}`
- Business logic:
  - aggregate monthly revenue theo pickup_zone + month + service_type
  - tổng hợp revenue components + trip metrics.
  - cross-db date trunc branch (BigQuery vs DuckDB).
- Materialization: `table` (inherits marts default).

**Copy nguyên văn:**
```sql
-- Data mart for monthly revenue analysis by pickup zone and service type
-- This aggregation is optimized for business reporting and dashboards
-- Enables analysis of revenue trends across different zones and taxi types

select
    -- Grouping dimensions
    coalesce(pickup_zone, 'Unknown Zone') as pickup_zone,
    {% if target.type == 'bigquery' %}cast(date_trunc(pickup_datetime, month) as date)
    {% elif target.type == 'duckdb' %}date_trunc('month', pickup_datetime)
    {% endif %} as revenue_month,
    service_type,

    -- Revenue breakdown (summed by zone, month, and service type)
    sum(fare_amount) as revenue_monthly_fare,
    sum(extra) as revenue_monthly_extra,
    sum(mta_tax) as revenue_monthly_mta_tax,
    sum(tip_amount) as revenue_monthly_tip_amount,
    sum(tolls_amount) as revenue_monthly_tolls_amount,
    sum(ehail_fee) as revenue_monthly_ehail_fee,
    sum(improvement_surcharge) as revenue_monthly_improvement_surcharge,
    sum(total_amount) as revenue_monthly_total_amount,

    -- Additional metrics for operational analysis
    count(trip_id) as total_monthly_trips,
    avg(passenger_count) as avg_monthly_passenger_count,
    avg(trip_distance) as avg_monthly_trip_distance

from {{ ref('fct_trips') }}
group by pickup_zone, revenue_month, service_type
```

## [Seeds .csv]

### `taxi_rides_ny/seeds/payment_type_lookup.csv`
- Columns: `payment_type`, `description`
- Sample data: đầy đủ file chỉ 8 dòng mapping từ 0..6.
- Mục đích: dimension lookup để enrich `payment_type_description` trong `int_trips`.

**Copy nguyên văn:**
```csv
payment_type,description
0,Unknown
1,Credit card
2,Cash
3,No charge
4,Dispute
5,Unknown
6,Voided trip
```

### `taxi_rides_ny/seeds/taxi_zone_lookup.csv`
- Columns: `locationid`, `borough`, `zone`, `service_zone`
- Sample data: file đầy đủ 265 location rows (EWR/Boro/Yellow/Airports + Unknown).
- Mục đích: lookup dimension zone để enrich pickup/dropoff trong `fct_trips` qua `dim_zones`.

**Copy nguyên văn:**
```csv
"locationid","borough","zone","service_zone"
1,"EWR","Newark Airport","EWR"
2,"Queens","Jamaica Bay","Boro Zone"
3,"Bronx","Allerton/Pelham Gardens","Boro Zone"
4,"Manhattan","Alphabet City","Yellow Zone"
5,"Staten Island","Arden Heights","Boro Zone"
6,"Staten Island","Arrochar/Fort Wadsworth","Boro Zone"
7,"Queens","Astoria","Boro Zone"
8,"Queens","Astoria Park","Boro Zone"
9,"Queens","Auburndale","Boro Zone"
10,"Queens","Baisley Park","Boro Zone"
11,"Brooklyn","Bath Beach","Boro Zone"
12,"Manhattan","Battery Park","Yellow Zone"
13,"Manhattan","Battery Park City","Yellow Zone"
14,"Brooklyn","Bay Ridge","Boro Zone"
15,"Queens","Bay Terrace/Fort Totten","Boro Zone"
16,"Queens","Bayside","Boro Zone"
17,"Brooklyn","Bedford","Boro Zone"
18,"Bronx","Bedford Park","Boro Zone"
19,"Queens","Bellerose","Boro Zone"
20,"Bronx","Belmont","Boro Zone"
21,"Brooklyn","Bensonhurst East","Boro Zone"
22,"Brooklyn","Bensonhurst West","Boro Zone"
23,"Staten Island","Bloomfield/Emerson Hill","Boro Zone"
24,"Manhattan","Bloomingdale","Yellow Zone"
25,"Brooklyn","Boerum Hill","Boro Zone"
26,"Brooklyn","Borough Park","Boro Zone"
27,"Queens","Breezy Point/Fort Tilden/Riis Beach","Boro Zone"
28,"Queens","Briarwood/Jamaica Hills","Boro Zone"
29,"Brooklyn","Brighton Beach","Boro Zone"
30,"Queens","Broad Channel","Boro Zone"
31,"Bronx","Bronx Park","Boro Zone"
32,"Bronx","Bronxdale","Boro Zone"
33,"Brooklyn","Brooklyn Heights","Boro Zone"
34,"Brooklyn","Brooklyn Navy Yard","Boro Zone"
35,"Brooklyn","Brownsville","Boro Zone"
36,"Brooklyn","Bushwick North","Boro Zone"
37,"Brooklyn","Bushwick South","Boro Zone"
38,"Queens","Cambria Heights","Boro Zone"
39,"Brooklyn","Canarsie","Boro Zone"
40,"Brooklyn","Carroll Gardens","Boro Zone"
41,"Manhattan","Central Harlem","Boro Zone"
42,"Manhattan","Central Harlem North","Boro Zone"
43,"Manhattan","Central Park","Yellow Zone"
44,"Staten Island","Charleston/Tottenville","Boro Zone"
45,"Manhattan","Chinatown","Yellow Zone"
46,"Bronx","City Island","Boro Zone"
47,"Bronx","Claremont/Bathgate","Boro Zone"
48,"Manhattan","Clinton East","Yellow Zone"
49,"Brooklyn","Clinton Hill","Boro Zone"
50,"Manhattan","Clinton West","Yellow Zone"
51,"Bronx","Co-Op City","Boro Zone"
52,"Brooklyn","Cobble Hill","Boro Zone"
53,"Queens","College Point","Boro Zone"
54,"Brooklyn","Columbia Street","Boro Zone"
55,"Brooklyn","Coney Island","Boro Zone"
56,"Queens","Corona","Boro Zone"
57,"Queens","Corona","Boro Zone"
58,"Bronx","Country Club","Boro Zone"
59,"Bronx","Crotona Park","Boro Zone"
60,"Bronx","Crotona Park East","Boro Zone"
61,"Brooklyn","Crown Heights North","Boro Zone"
62,"Brooklyn","Crown Heights South","Boro Zone"
63,"Brooklyn","Cypress Hills","Boro Zone"
64,"Queens","Douglaston","Boro Zone"
65,"Brooklyn","Downtown Brooklyn/MetroTech","Boro Zone"
66,"Brooklyn","DUMBO/Vinegar Hill","Boro Zone"
67,"Brooklyn","Dyker Heights","Boro Zone"
68,"Manhattan","East Chelsea","Yellow Zone"
69,"Bronx","East Concourse/Concourse Village","Boro Zone"
70,"Queens","East Elmhurst","Boro Zone"
71,"Brooklyn","East Flatbush/Farragut","Boro Zone"
72,"Brooklyn","East Flatbush/Remsen Village","Boro Zone"
73,"Queens","East Flushing","Boro Zone"
74,"Manhattan","East Harlem North","Boro Zone"
75,"Manhattan","East Harlem South","Boro Zone"
76,"Brooklyn","East New York","Boro Zone"
77,"Brooklyn","East New York/Pennsylvania Avenue","Boro Zone"
78,"Bronx","East Tremont","Boro Zone"
79,"Manhattan","East Village","Yellow Zone"
80,"Brooklyn","East Williamsburg","Boro Zone"
81,"Bronx","Eastchester","Boro Zone"
82,"Queens","Elmhurst","Boro Zone"
83,"Queens","Elmhurst/Maspeth","Boro Zone"
84,"Staten Island","Eltingville/Annadale/Prince's Bay","Boro Zone"
85,"Brooklyn","Erasmus","Boro Zone"
86,"Queens","Far Rockaway","Boro Zone"
87,"Manhattan","Financial District North","Yellow Zone"
88,"Manhattan","Financial District South","Yellow Zone"
89,"Brooklyn","Flatbush/Ditmas Park","Boro Zone"
90,"Manhattan","Flatiron","Yellow Zone"
91,"Brooklyn","Flatlands","Boro Zone"
92,"Queens","Flushing","Boro Zone"
93,"Queens","Flushing Meadows-Corona Park","Boro Zone"
94,"Bronx","Fordham South","Boro Zone"
95,"Queens","Forest Hills","Boro Zone"
96,"Queens","Forest Park/Highland Park","Boro Zone"
97,"Brooklyn","Fort Greene","Boro Zone"
98,"Queens","Fresh Meadows","Boro Zone"
99,"Staten Island","Freshkills Park","Boro Zone"
100,"Manhattan","Garment District","Yellow Zone"
101,"Queens","Glen Oaks","Boro Zone"
102,"Queens","Glendale","Boro Zone"
103,"Manhattan","Governor's Island/Ellis Island/Liberty Island","Yellow Zone"
104,"Manhattan","Governor's Island/Ellis Island/Liberty Island","Yellow Zone"
105,"Manhattan","Governor's Island/Ellis Island/Liberty Island","Yellow Zone"
106,"Brooklyn","Gowanus","Boro Zone"
107,"Manhattan","Gramercy","Yellow Zone"
108,"Brooklyn","Gravesend","Boro Zone"
109,"Staten Island","Great Kills","Boro Zone"
110,"Staten Island","Great Kills Park","Boro Zone"
111,"Brooklyn","Green-Wood Cemetery","Boro Zone"
112,"Brooklyn","Greenpoint","Boro Zone"
113,"Manhattan","Greenwich Village North","Yellow Zone"
114,"Manhattan","Greenwich Village South","Yellow Zone"
115,"Staten Island","Grymes Hill/Clifton","Boro Zone"
116,"Manhattan","Hamilton Heights","Boro Zone"
117,"Queens","Hammels/Arverne","Boro Zone"
118,"Staten Island","Heartland Village/Todt Hill","Boro Zone"
119,"Bronx","Highbridge","Boro Zone"
120,"Manhattan","Highbridge Park","Boro Zone"
121,"Queens","Hillcrest/Pomonok","Boro Zone"
122,"Queens","Hollis","Boro Zone"
123,"Brooklyn","Homecrest","Boro Zone"
124,"Queens","Howard Beach","Boro Zone"
125,"Manhattan","Hudson Sq","Yellow Zone"
126,"Bronx","Hunts Point","Boro Zone"
127,"Manhattan","Inwood","Boro Zone"
128,"Manhattan","Inwood Hill Park","Boro Zone"
129,"Queens","Jackson Heights","Boro Zone"
130,"Queens","Jamaica","Boro Zone"
131,"Queens","Jamaica Estates","Boro Zone"
132,"Queens","JFK Airport","Airports"
133,"Brooklyn","Kensington","Boro Zone"
134,"Queens","Kew Gardens","Boro Zone"
135,"Queens","Kew Gardens Hills","Boro Zone"
136,"Bronx","Kingsbridge Heights","Boro Zone"
137,"Manhattan","Kips Bay","Yellow Zone"
138,"Queens","LaGuardia Airport","Airports"
139,"Queens","Laurelton","Boro Zone"
140,"Manhattan","Lenox Hill East","Yellow Zone"
141,"Manhattan","Lenox Hill West","Yellow Zone"
142,"Manhattan","Lincoln Square East","Yellow Zone"
143,"Manhattan","Lincoln Square West","Yellow Zone"
144,"Manhattan","Little Italy/NoLiTa","Yellow Zone"
145,"Queens","Long Island City/Hunters Point","Boro Zone"
146,"Queens","Long Island City/Queens Plaza","Boro Zone"
147,"Bronx","Longwood","Boro Zone"
148,"Manhattan","Lower East Side","Yellow Zone"
149,"Brooklyn","Madison","Boro Zone"
150,"Brooklyn","Manhattan Beach","Boro Zone"
151,"Manhattan","Manhattan Valley","Yellow Zone"
152,"Manhattan","Manhattanville","Boro Zone"
153,"Manhattan","Marble Hill","Boro Zone"
154,"Brooklyn","Marine Park/Floyd Bennett Field","Boro Zone"
155,"Brooklyn","Marine Park/Mill Basin","Boro Zone"
156,"Staten Island","Mariners Harbor","Boro Zone"
157,"Queens","Maspeth","Boro Zone"
158,"Manhattan","Meatpacking/West Village West","Yellow Zone"
159,"Bronx","Melrose South","Boro Zone"
160,"Queens","Middle Village","Boro Zone"
161,"Manhattan","Midtown Center","Yellow Zone"
162,"Manhattan","Midtown East","Yellow Zone"
163,"Manhattan","Midtown North","Yellow Zone"
164,"Manhattan","Midtown South","Yellow Zone"
165,"Brooklyn","Midwood","Boro Zone"
166,"Manhattan","Morningside Heights","Boro Zone"
167,"Bronx","Morrisania/Melrose","Boro Zone"
168,"Bronx","Mott Haven/Port Morris","Boro Zone"
169,"Bronx","Mount Hope","Boro Zone"
170,"Manhattan","Murray Hill","Yellow Zone"
171,"Queens","Murray Hill-Queens","Boro Zone"
172,"Staten Island","New Dorp/Midland Beach","Boro Zone"
173,"Queens","North Corona","Boro Zone"
174,"Bronx","Norwood","Boro Zone"
175,"Queens","Oakland Gardens","Boro Zone"
176,"Staten Island","Oakwood","Boro Zone"
177,"Brooklyn","Ocean Hill","Boro Zone"
178,"Brooklyn","Ocean Parkway South","Boro Zone"
179,"Queens","Old Astoria","Boro Zone"
180,"Queens","Ozone Park","Boro Zone"
181,"Brooklyn","Park Slope","Boro Zone"
182,"Bronx","Parkchester","Boro Zone"
183,"Bronx","Pelham Bay","Boro Zone"
184,"Bronx","Pelham Bay Park","Boro Zone"
185,"Bronx","Pelham Parkway","Boro Zone"
186,"Manhattan","Penn Station/Madison Sq West","Yellow Zone"
187,"Staten Island","Port Richmond","Boro Zone"
188,"Brooklyn","Prospect-Lefferts Gardens","Boro Zone"
189,"Brooklyn","Prospect Heights","Boro Zone"
190,"Brooklyn","Prospect Park","Boro Zone"
191,"Queens","Queens Village","Boro Zone"
192,"Queens","Queensboro Hill","Boro Zone"
193,"Queens","Queensbridge/Ravenswood","Boro Zone"
194,"Manhattan","Randalls Island","Yellow Zone"
195,"Brooklyn","Red Hook","Boro Zone"
196,"Queens","Rego Park","Boro Zone"
197,"Queens","Richmond Hill","Boro Zone"
198,"Queens","Ridgewood","Boro Zone"
199,"Bronx","Rikers Island","Boro Zone"
200,"Bronx","Riverdale/North Riverdale/Fieldston","Boro Zone"
201,"Queens","Rockaway Park","Boro Zone"
202,"Manhattan","Roosevelt Island","Boro Zone"
203,"Queens","Rosedale","Boro Zone"
204,"Staten Island","Rossville/Woodrow","Boro Zone"
205,"Queens","Saint Albans","Boro Zone"
206,"Staten Island","Saint George/New Brighton","Boro Zone"
207,"Queens","Saint Michaels Cemetery/Woodside","Boro Zone"
208,"Bronx","Schuylerville/Edgewater Park","Boro Zone"
209,"Manhattan","Seaport","Yellow Zone"
210,"Brooklyn","Sheepshead Bay","Boro Zone"
211,"Manhattan","SoHo","Yellow Zone"
212,"Bronx","Soundview/Bruckner","Boro Zone"
213,"Bronx","Soundview/Castle Hill","Boro Zone"
214,"Staten Island","South Beach/Dongan Hills","Boro Zone"
215,"Queens","South Jamaica","Boro Zone"
216,"Queens","South Ozone Park","Boro Zone"
217,"Brooklyn","South Williamsburg","Boro Zone"
218,"Queens","Springfield Gardens North","Boro Zone"
219,"Queens","Springfield Gardens South","Boro Zone"
220,"Bronx","Spuyten Duyvil/Kingsbridge","Boro Zone"
221,"Staten Island","Stapleton","Boro Zone"
222,"Brooklyn","Starrett City","Boro Zone"
223,"Queens","Steinway","Boro Zone"
224,"Manhattan","Stuy Town/Peter Cooper Village","Yellow Zone"
225,"Brooklyn","Stuyvesant Heights","Boro Zone"
226,"Queens","Sunnyside","Boro Zone"
227,"Brooklyn","Sunset Park East","Boro Zone"
228,"Brooklyn","Sunset Park West","Boro Zone"
229,"Manhattan","Sutton Place/Turtle Bay North","Yellow Zone"
230,"Manhattan","Times Sq/Theatre District","Yellow Zone"
231,"Manhattan","TriBeCa/Civic Center","Yellow Zone"
232,"Manhattan","Two Bridges/Seward Park","Yellow Zone"
233,"Manhattan","UN/Turtle Bay South","Yellow Zone"
234,"Manhattan","Union Sq","Yellow Zone"
235,"Bronx","University Heights/Morris Heights","Boro Zone"
236,"Manhattan","Upper East Side North","Yellow Zone"
237,"Manhattan","Upper East Side South","Yellow Zone"
238,"Manhattan","Upper West Side North","Yellow Zone"
239,"Manhattan","Upper West Side South","Yellow Zone"
240,"Bronx","Van Cortlandt Park","Boro Zone"
241,"Bronx","Van Cortlandt Village","Boro Zone"
242,"Bronx","Van Nest/Morris Park","Boro Zone"
243,"Manhattan","Washington Heights North","Boro Zone"
244,"Manhattan","Washington Heights South","Boro Zone"
245,"Staten Island","West Brighton","Boro Zone"
246,"Manhattan","West Chelsea/Hudson Yards","Yellow Zone"
247,"Bronx","West Concourse","Boro Zone"
248,"Bronx","West Farms/Bronx River","Boro Zone"
249,"Manhattan","West Village","Yellow Zone"
250,"Bronx","Westchester Village/Unionport","Boro Zone"
251,"Staten Island","Westerleigh","Boro Zone"
252,"Queens","Whitestone","Boro Zone"
253,"Queens","Willets Point","Boro Zone"
254,"Bronx","Williamsbridge/Olinville","Boro Zone"
255,"Brooklyn","Williamsburg (North Side)","Boro Zone"
256,"Brooklyn","Williamsburg (South Side)","Boro Zone"
257,"Brooklyn","Windsor Terrace","Boro Zone"
258,"Queens","Woodhaven","Boro Zone"
259,"Bronx","Woodlawn/Wakefield","Boro Zone"
260,"Queens","Woodside","Boro Zone"
261,"Manhattan","World Trade Center","Yellow Zone"
262,"Manhattan","Yorkville East","Yellow Zone"
263,"Manhattan","Yorkville West","Yellow Zone"
264,"Unknown","NV","N/A"
265,"Unknown","NA","N/A"
```

## [ROOT README.md]
- File tồn tại ở `04-analytics-engineering/README.md` (đã phân tích ở mục .MD bên trên).
- Không tìm thấy `04-analytics-engineering/taxi_rides_ny/README.md` trong repo hiện tại.

---

# 4. DATA FLOW THỰC TẾ

## DAG đầy đủ (source → staging → intermediate → marts → reporting)

```text
raw.green_tripdata ---------------------> stg_green_tripdata (view)
raw.yellow_tripdata -------------------> stg_yellow_tripdata (view)

stg_green_tripdata ----\
                         > int_trips_unioned (table)
stg_yellow_tripdata ---/

payment_type_lookup (seed) -----------> int_trips (table)
int_trips_unioned --------------------> int_trips (table)

taxi_zone_lookup (seed) --------------> dim_zones (table)
int_trips + dim_zones ----------------> fct_trips (incremental merge)

fct_trips ----------------------------> dim_vendors (table)
fct_trips ----------------------------> fct_monthly_zone_revenue (table, reporting)
```

## Lineage graph dạng text (file nào ref file nào)

- `models/staging/stg_green_tripdata.sql`
  - `source('raw', 'green_tripdata')`
  - macro call: `safe_cast`
- `models/staging/stg_yellow_tripdata.sql`
  - `source('raw', 'yellow_tripdata')`
- `models/intermediate/int_trips_unioned.sql`
  - `ref('stg_green_tripdata')`
  - `ref('stg_yellow_tripdata')`
- `models/intermediate/int_trips.sql`
  - `ref('int_trips_unioned')`
  - `ref('payment_type_lookup')`
  - macro call: `dbt_utils.generate_surrogate_key`
- `models/marts/dim_zones.sql`
  - `ref('taxi_zone_lookup')`
- `models/marts/fct_trips.sql`
  - `ref('int_trips')`
  - `ref('dim_zones')` (pickup)
  - `ref('dim_zones')` (dropoff)
  - macro call: `get_trip_duration_minutes`
- `models/marts/dim_vendors.sql`
  - `ref('fct_trips')`
  - macro call: `get_vendor_data`
- `models/marts/reporting/fct_monthly_zone_revenue.sql`
  - `ref('fct_trips')`

## Thứ tự chạy đúng theo dependency

1. `dbt seed`:
   - `payment_type_lookup`
   - `taxi_zone_lookup`
2. staging views:
   - `stg_green_tripdata`
   - `stg_yellow_tripdata`
3. intermediate tables:
   - `int_trips_unioned`
   - `int_trips`
4. marts:
   - `dim_zones` (chỉ phụ thuộc seed)
   - `fct_trips` (phụ thuộc `int_trips` + `dim_zones`)
   - `dim_vendors` (phụ thuộc `fct_trips`)
5. reporting:
   - `fct_monthly_zone_revenue` (phụ thuộc `fct_trips`)

## Materialization strategy theo layer

- Staging: `view` (global default)
- Intermediate: `table` (global default)
- Marts: `table` (global default)
- Exception:
  - `marts/fct_trips.sql`: `incremental` + `merge` + `unique_key=trip_id`

---

# 5. ĐIỂM YẾU & THIẾU SÓT

## Test coverage gaps

- Nhiều cột quan trọng chưa có tests:
  - `pickup_location_id`, `dropoff_location_id`, `payment_type`, `trip_distance`, `fare_amount`, `trip_duration_minutes`.
- `sources.yml` có freshness ở source-level nhưng không có table-level freshness per table granularity.
- Không có singular tests nào trong `tests/` (folder chỉ có `.gitkeep`).
- Không có unit tests dù notes module có dạy unit tests.

## Hardcode issues

- Dev sampling hardcode trong cả 2 staging models:
  - `where pickup_datetime >= '2019-01-01' and pickup_datetime < '2019-02-01'`
  - Không dùng vars `dev_start_date`, `dev_end_date` đã định nghĩa trong `dbt_project.yml`.
- `int_trips_unioned` hardcode:
  - `trip_type = 1` cho yellow.
  - `ehail_fee = 0` cho yellow.
  - Logic đúng nghiệp vụ hiện tại nhưng hardcoded assumption.
- `sources.yml` dùng default env var fallback:
  - `'please-add-your-gcp-project-id-here'` có thể gây lỗi runtime nếu quên set env.

## Incremental model issues

- `fct_trips` incremental filter:
  - `where trips.pickup_datetime > (select max(pickup_datetime) from {{ this }})`
  - Rủi ro bỏ sót record late-arriving có `pickup_datetime` cũ hơn max hiện tại.
- Không có reprocessing window (ví dụ last N days) cho late data.
- `on_schema_change='append_new_columns'` có thể tăng schema drift nếu nguồn đổi thất thường.

## Macro design issues

- `get_vendor_data` map cứng dictionary trong code:
  - cần deploy lại code mỗi khi thêm vendor mới.
  - scalable kém hơn dùng seed/table dimension riêng.
- `safe_cast` chỉ special-case BigQuery, còn lại cast thường; không xử lý invalid cast ở non-BQ adapters.

## Seeds dùng trong production: rủi ro

- Seeds nằm trong git:
  - dễ drift so với source-of-truth ngoài hệ thống (nếu có).
  - update data lookup cần PR/code release, không phù hợp dữ liệu thay đổi thường xuyên.
- `taxi_zone_lookup.csv` khá lớn để version-control nhưng vẫn chấp nhận được cho lookup static.
- Nếu business đổi taxonomy zone/vendor/payment, seed update lifecycle có thể chậm.

## Documentation gaps

- Có docs tốt ở model/column level nhưng thiếu:
  - business SLA/freshness expectations ở model level.
  - owner/contact metadata (`meta.owner`) cho từng data asset.
  - explicit grain statement cho tất cả models (đặc biệt intermediate/reporting).
- Không có README riêng trong `taxi_rides_ny/` để hướng dẫn dev runbook tại project root.

## Những gì repo dạy nhưng chưa đủ cho Senior DE/Analytics Engineer

- Chưa cover sâu về:
  - CI/CD chuẩn production cho dbt (state artifacts management, slim CI end-to-end).
  - observability/alerting vận hành data products.
  - advanced incremental strategies (merge predicates, delete+insert windows, backfills).
  - governance/data contracts end-to-end với consumers.

---

# 6. KIẾN THỨC NGOÀI REPO

## dbt Core/Cloud: concept Senior cần biết nhưng repo chưa dạy đủ
- dbt Mesh (multi-project dependencies, package contracts giữa teams).
- Deferral + state comparison nâng cao (prod manifest defer vào CI/dev).
- Artifact APIs, metadata ingestion từ `manifest.json`/`run_results.json` vào observability stack.
- dbt Cloud job orchestration nâng cao (job graph, environment promotion, SLAs).
- Access control/RBAC và secure credential patterns ở scale.
- Fusion engine migration strategies và adapter compatibility governance.

## Data Modeling
- Advanced dimensional modeling:
  - SCD Type 2/6 patterns cho dimensions biến động.
  - fact grain governance, additive/semi-additive metrics.
- Data Vault / hybrid Kimball-Data Vault tradeoff.
- Semantic layer modeling (metrics as code, centrally governed definitions).
- Handling late-arriving facts/dimensions với reconciliation strategies.
- Timezone and calendar conformance model (fiscal calendars, holiday calendars).

## Testing & Data Quality
- Data quality framework theo severity tiers (warn/error/block deploy).
- Distribution/anomaly tests (drift detection) beyond schema tests.
- Contract tests với downstream consumers + backward compatibility checks.
- Differential testing (old vs new model result equivalence at scale).
- Freshness + volume + nullity SLIs kèm alert routing.

## Performance & Optimization
- Partitioning/clustering strategy per warehouse (BigQuery/Snowflake/Databricks specifics).
- Cost-based query optimization (slot usage, bytes scanned, pruning diagnostics).
- Incremental predicate tuning + merge performance optimization.
- Materialization decision framework (table/view/incremental/ephemeral) theo workload.
- Concurrency tuning, thread strategy, warehouse sizing policy.

## CI/CD cho dbt project
- Slim CI đầy đủ:
  - state:modified+ build
  - defer to prod artifacts
  - PR comment artifacts lineage/tests
- Multi-env promotion pipeline (dev -> staging -> prod) với approvals.
- Rollback strategy theo artifact/versioned deployment.
- Policy checks (linting SQL/YAML, naming conventions, contract gate).
- Automated docs publish + lineage diff mỗi PR.

## Orchestration & Scheduling
- Production orchestration with Airflow/Prefect/Dagster/Kestra:
  - dependency with upstream ingestion jobs.
  - idempotent retries and failure semantics.
- Event-driven runs (source freshness triggers, pub/sub events).
- Backfill orchestration patterns (date range chunking, checkpointing).
- SLA-aware scheduling and alerting (on-call integration).
- End-to-end observability across ingestion + transform + serving.

---

## Phụ lục: file bổ sung đã đọc trong project root

### `taxi_rides_ny/.gitignore` (copy nguyên văn)
```gitignore
# you shouldn't commit these into source control
# these are the default directory names, adjust/add to fit your needs
target/
dbt_packages/
logs/
profiles.yml
.user.yml

# Data files for DuckDB
data/green_tripdata/
data/yellow_tripdata/
data/
*.duckdb
*.duckdb.wal
.duckdb_temp/

# Parquet data files
*.parquet

# Python artifacts
__pycache__/
*.py[cod]
*$py.class
*.so
.Python
build/
develop-eggs/
dist/
downloads/
eggs/
.eggs/
lib/
lib64/
parts/
sdist/
var/
wheels/
pip-wheel-metadata/
share/python-wheels/
*.egg-info/
.installed.cfg
*.egg
MANIFEST

# Virtual environments
venv/
env/
ENV/
env.bak/
venv.bak/
.venv/

# PyCharm
.idea/

# VS Code
.vscode/

# Jupyter Notebook
.ipynb_checkpoints
*.ipynb

# pyenv
.python-version

# pytest
.pytest_cache/
.coverage
htmlcov/

# mypy
.mypy_cache/
.dmypy.json
dmypy.json

# GCP credentials and service account keys
*-key.json
*-keys.json
*key*.json
*credential*.json
*service-account*.json
*serviceaccount*.json
service-account.json
serviceaccount.json
gcp-*.json
google-*.json

# Environment variables
.env
.env.local
.env.*.local
*.env
dbt_internal_packages/
```

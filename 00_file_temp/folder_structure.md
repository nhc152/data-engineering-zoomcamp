# Cấu trúc thư mục `data-engineering-zoomcamp`

Dưới đây là cấu trúc thư mục và file chi tiết, đầy đủ của dự án (đã loại bỏ các thư mục ẩn như `.git`, `.venv`, `__pycache__` để dễ nhìn hơn):

```text
data-engineering-zoomcamp/
├── 01-docker-terraform/
│   ├── docker-sql/
│   │   ├── pipeline/
│   │   │   ├── docker-helper-scripts/
│   │   │   │   ├── docker-ingest.sh
│   │   │   │   ├── docker-pgadmin.sh
│   │   │   │   └── docker-postgres.sh
│   │   │   ├── .python-version
│   │   │   ├── Dockerfile
│   │   │   ├── docker-compose.yaml
│   │   │   ├── ingest_data.py
│   │   │   └── pyproject.toml
│   │   ├── 01-introduction.md
│   │   ├── 02-virtual-environment.md
│   │   ├── 03-dockerizing-pipeline.md
│   │   ├── 04-postgres-docker.md
│   │   ├── 05-data-ingestion.md
│   │   ├── 06-ingestion-script.md
│   │   ├── 07-pgadmin.md
│   │   ├── 08-dockerizing-ingestion.md
│   │   ├── 09-docker-compose.md
│   │   ├── 10-sql-refresher.md
│   │   ├── 11-cleanup.md
│   │   └── README.md
│   ├── terraform/
│   │   ├── terraform/
│   │   │   ├── terraform_basic/
│   │   │   │   └── main.tf
│   │   │   ├── terraform_with_variable_AWS/
│   │   │   │   ├── README.md
│   │   │   │   ├── main.tf
│   │   │   │   ├── terraform.tfvars
│   │   │   │   └── variables.tf
│   │   │   ├── terraform_with_variables/
│   │   │   │   ├── main.tf
│   │   │   │   └── variables.tf
│   │   │   └── README.md
│   │   ├── 1_terraform_overview.md
│   │   ├── 2_gcp_overview.md
│   │   ├── README.md
│   │   └── windows.md
│   └── README.md
├── 02-workflow-orchestration/
│   ├── flows/
│   │   ├── 01_hello_world.yaml
│   │   ├── 02_python.yaml
│   │   ├── 03_getting_started_data_pipeline.yaml
│   │   ├── 04_postgres_taxi.yaml
│   │   ├── 05_postgres_taxi_scheduled.yaml
│   │   ├── 06_gcp_kv.yaml
│   │   ├── 07_gcp_setup.yaml
│   │   ├── 08_gcp_taxi.yaml
│   │   ├── 09_gcp_taxi_scheduled.yaml
│   │   ├── 10_chat_without_rag.yaml
│   │   └── 11_chat_with_rag.yaml
│   ├── images/
│   │   └── homework.png
│   ├── README.md
│   └── docker-compose.yml
├── 03-data-warehouse/
│   ├── extras/
│   │   ├── .env-example
│   │   ├── .gitignore
│   │   ├── README.md
│   │   ├── pyproject.toml
│   │   ├── web_to_gcs.py
│   │   └── web_to_gcs_with_progress_bar.py
│   ├── README.md
│   ├── big_query.sql
│   ├── big_query_hw.sql
│   ├── big_query_ml.sql
│   └── extract_model.md
├── 04-analytics-engineering/
│   ├── class_notes/
│   │   ├── 4_1_1_analytics_engineering_basics.md
│   │   ├── 4_1_2_what_is_dbt.md
│   │   ├── 4_2_1_dbt_core_vs_dbt_cloud.md
│   │   ├── 4_3_1_dbt_project_structure.md
│   │   ├── 4_3_2_dbt_sources.md
│   │   ├── 4_4_1_dbt_models.md
│   │   ├── 4_4_2_dbt_seeds_and_macros.md
│   │   ├── 4_5_1_documentation.md
│   │   ├── 4_5_2_dbt_tests.md
│   │   ├── 4_5_3_dbt_packages.md
│   │   └── 4_6_1_dbt_commands.md
│   ├── refreshers/
│   │   └── SQL.md
│   ├── setup/
│   │   ├── cloud_setup.md
│   │   ├── duckdb_troubleshooting.md
│   │   └── local_setup.md
│   ├── taxi_rides_ny/
│   │   ├── macros/
│   │   │   ├── get_trip_duration_minutes.sql
│   │   │   ├── get_vendor_data.sql
│   │   │   ├── macros_properties.yml
│   │   │   └── safe_cast.sql
│   │   ├── models/
│   │   │   ├── intermediate/
│   │   │   │   ├── int_trips.sql
│   │   │   │   ├── int_trips_unioned.sql
│   │   │   │   └── schema.yml
│   │   │   ├── marts/
│   │   │   │   ├── reporting/
│   │   │   │   │   ├── fct_monthly_zone_revenue.sql
│   │   │   │   │   └── schema.yml
│   │   │   │   ├── dim_vendors.sql
│   │   │   │   ├── dim_zones.sql
│   │   │   │   ├── fct_trips.sql
│   │   │   │   └── schema.yml
│   │   │   └── staging/
│   │   │       ├── schema.yml
│   │   │       ├── sources.yml
│   │   │       ├── stg_green_tripdata.sql
│   │   │       └── stg_yellow_tripdata.sql
│   │   ├── seeds/
│   │   │   ├── payment_type_lookup.csv
│   │   │   ├── seeds_properties.yml
│   │   │   └── taxi_zone_lookup.csv
│   │   ├── snapshots/
│   │   │   └── .gitkeep
│   │   ├── tests/
│   │   │   └── .gitkeep
│   │   ├── .gitignore
│   │   ├── dbt_project.yml
│   │   ├── package-lock.yml
│   │   └── packages.yml
│   └── README.md
├── 05-data-platforms/
│   ├── notes/
│   │   ├── 01-introduction.md
│   │   ├── 02-getting-started.md
│   │   ├── 03-nyc-taxi-pipeline.md
│   │   ├── 04-bruin-mcp.md
│   │   ├── 05-bruin-cloud.md
│   │   ├── 06-core-01-projects.md
│   │   ├── 06-core-02-pipelines.md
│   │   ├── 06-core-03-assets.md
│   │   ├── 06-core-04-variables.md
│   │   └── 06-core-05-commands.md
│   └── README.md
├── 06-batch/
│   ├── code/
│   │   ├── 03_test.ipynb
│   │   ├── 04_pyspark.ipynb
│   │   ├── 05_taxi_schema.ipynb
│   │   ├── 06_spark_sql.ipynb
│   │   ├── 06_spark_sql.py
│   │   ├── 06_spark_sql_big_query.py
│   │   ├── 07_groupby_join.ipynb
│   │   ├── 08_rdds.ipynb
│   │   ├── 09_spark_gcs.ipynb
│   │   ├── cloud.md
│   │   ├── download_data.sh
│   │   └── homework.ipynb
│   ├── setup/
│   │   ├── config/
│   │   │   ├── core-site.xml
│   │   │   ├── spark-defaults.conf
│   │   │   └── spark.dockerfile
│   │   ├── hadoop-yarn.md
│   │   ├── linux.md
│   │   ├── macos.md
│   │   └── windows.md
│   ├── .gitignore
│   └── README.md
├── 07-streaming/
│   ├── extras/
│   │   ├── ksqldb/
│   │   │   └── commands.md
│   │   ├── pyflink/
│   │   │   ├── src/
│   │   │   │   ├── job/
│   │   │   │   │   ├── aggregation_job.py
│   │   │   │   │   ├── start_job.py
│   │   │   │   │   └── taxi_job.py
│   │   │   │   └── producers/
│   │   │   │       ├── load_taxi_data.py
│   │   │   │       └── producer.py
│   │   │   ├── .gitignore
│   │   │   ├── Dockerfile.flink
│   │   │   ├── LICENSE
│   │   │   ├── Makefile
│   │   │   ├── README.md
│   │   │   ├── docker-compose.yml
│   │   │   ├── homework.md
│   │   │   └── requirements.txt
│   │   ├── python/
│   │   │   ├── avro_example/
│   │   │   │   ├── consumer.py
│   │   │   │   ├── producer.py
│   │   │   │   ├── ride_record.py
│   │   │   │   ├── ride_record_key.py
│   │   │   │   └── settings.py
│   │   │   ├── docker/
│   │   │   │   ├── kafka/
│   │   │   │   │   └── docker-compose.yml
│   │   │   │   ├── spark/
│   │   │   │   │   ├── build.sh
│   │   │   │   │   ├── cluster-base.Dockerfile
│   │   │   │   │   ├── docker-compose.yml
│   │   │   │   │   ├── jupyterlab.Dockerfile
│   │   │   │   │   ├── spark-base.Dockerfile
│   │   │   │   │   ├── spark-master.Dockerfile
│   │   │   │   │   └── spark-worker.Dockerfile
│   │   │   │   ├── README.md
│   │   │   │   └── docker-compose.yml
│   │   │   ├── json_example/
│   │   │   │   ├── consumer.py
│   │   │   │   ├── producer.py
│   │   │   │   ├── ride.py
│   │   │   │   └── settings.py
│   │   │   ├── redpanda_example/
│   │   │   │   ├── README.md
│   │   │   │   ├── consumer.py
│   │   │   │   ├── docker-compose.yaml
│   │   │   │   ├── producer.py
│   │   │   │   ├── ride.py
│   │   │   │   └── settings.py
│   │   │   ├── resources/
│   │   │   │   ├── schemas/
│   │   │   │   │   ├── taxi_ride_key.avsc
│   │   │   │   │   └── taxi_ride_value.avsc
│   │   │   │   └── rides.csv
│   │   │   ├── streams-example/
│   │   │   │   ├── faust/
│   │   │   │   │   ├── branch_price.py
│   │   │   │   │   ├── producer_taxi_json.py
│   │   │   │   │   ├── stream.py
│   │   │   │   │   ├── stream_count_vendor_trips.py
│   │   │   │   │   ├── taxi_rides.py
│   │   │   │   │   └── windowing.py
│   │   │   │   ├── pyspark/
│   │   │   │   │   ├── README.md
│   │   │   │   │   ├── consumer.py
│   │   │   │   │   ├── producer.py
│   │   │   │   │   ├── settings.py
│   │   │   │   │   ├── spark-submit.sh
│   │   │   │   │   ├── streaming-notebook.ipynb
│   │   │   │   │   └── streaming.py
│   │   │   │   └── redpanda/
│   │   │   │       ├── README.md
│   │   │   │       ├── consumer.py
│   │   │   │       ├── docker-compose.yaml
│   │   │   │       ├── producer.py
│   │   │   │       ├── settings.py
│   │   │   │       ├── spark-submit.sh
│   │   │   │       ├── streaming-notebook.ipynb
│   │   │   │       └── streaming.py
│   │   │   ├── README.md
│   │   │   └── requirements.txt
│   │   └── README.md
│   ├── theory/
│   │   ├── java/
│   │   │   └── kafka_examples/
│   │   │       ├── build/
│   │   │       │   └── generated-main-avro-java/
│   │   │       │       └── schemaregistry/
│   │   │       │           ├── RideRecord.java
│   │   │       │           ├── RideRecordCompatible.java
│   │   │       │           └── RideRecordNoneCompatible.java
│   │   │       ├── gradle/
│   │   │       │   └── wrapper/
│   │   │       │       ├── gradle-wrapper.jar
│   │   │       │       └── gradle-wrapper.properties
│   │   │       ├── src/
│   │   │       │   ├── main/
│   │   │       │   │   ├── avro/
│   │   │       │   │   │   ├── rides.avsc
│   │   │       │   │   │   ├── rides_compatible.avsc
│   │   │       │   │   │   └── rides_non_compatible.avsc
│   │   │       │   │   ├── java/
│   │   │       │   │   │   └── org/
│   │   │       │   │   │       └── example/
│   │   │       │   │   │           ├── customserdes/
│   │   │       │   │   │           │   └── CustomSerdes.java
│   │   │       │   │   │           ├── data/
│   │   │       │   │   │           │   ├── PickupLocation.java
│   │   │       │   │   │           │   ├── Ride.java
│   │   │       │   │   │           │   └── VendorInfo.java
│   │   │       │   │   │           ├── AvroProducer.java
│   │   │       │   │   │           ├── JsonConsumer.java
│   │   │       │   │   │           ├── JsonKStream.java
│   │   │       │   │   │           ├── JsonKStreamJoins.java
│   │   │       │   │   │           ├── JsonKStreamWindow.java
│   │   │       │   │   │           ├── JsonProducer.java
│   │   │       │   │   │           ├── JsonProducerPickupLocation.java
│   │   │       │   │   │           ├── Secrets.java
│   │   │       │   │   │           └── Topics.java
│   │   │       │   │   └── resources/
│   │   │       │   │       └── rides.csv
│   │   │       │   └── test/
│   │   │       │       └── java/
│   │   │       │           └── org/
│   │   │       │               └── example/
│   │   │       │                   ├── helper/
│   │   │       │                   │   └── DataGeneratorHelper.java
│   │   │       │                   ├── JsonKStreamJoinsTest.java
│   │   │       │                   └── JsonKStreamTest.java
│   │   │       ├── .gitignore
│   │   │       ├── build.gradle
│   │   │       ├── gradlew
│   │   │       ├── gradlew.bat
│   │   │       └── settings.gradle
│   │   └── README.md
│   ├── workshop/
│   │   ├── live/
│   │   │   ├── notebooks/
│   │   │   │   ├── consumer_db.ipynb
│   │   │   │   ├── models.py
│   │   │   │   └── producer.ipynb
│   │   │   ├── src/
│   │   │   │   ├── job/
│   │   │   │   │   ├── aggregation_job.py
│   │   │   │   │   └── pass_through_job.py
│   │   │   │   └── producers/
│   │   │   │       ├── models.py
│   │   │   │       └── producer_realtime.py
│   │   │   ├── .gitignore
│   │   │   ├── .python-version
│   │   │   ├── Dockerfile.flink
│   │   │   ├── README.md
│   │   │   ├── docker-compose.yaml
│   │   │   ├── flink-config.yaml
│   │   │   ├── main.py
│   │   │   ├── pyproject.flink.toml
│   │   │   ├── pyproject.toml
│   │   │   └── uv.lock
│   │   ├── src/
│   │   │   ├── consumers/
│   │   │   │   ├── consumer.py
│   │   │   │   └── consumer_postgres.py
│   │   │   ├── job/
│   │   │   │   ├── aggregation_job.py
│   │   │   │   ├── aggregation_job_demo.py
│   │   │   │   └── pass_through_job.py
│   │   │   ├── producers/
│   │   │   │   ├── producer.py
│   │   │   │   └── producer_realtime.py
│   │   │   └── models.py
│   │   ├── .python-version
│   │   ├── Dockerfile.flink
│   │   ├── Dockerfile_ARM64.flink
│   │   ├── Makefile
│   │   ├── README.md
│   │   ├── docker-compose.yml
│   │   ├── flink-config.yaml
│   │   ├── pyproject.flink.toml
│   │   ├── pyproject.toml
│   │   └── uv.lock
│   ├── .gitignore
│   └── README.md
├── cohorts/
│   ├── 2022/
│   │   ├── week_1_basics_n_setup/
│   │   │   └── homework.md
│   │   ├── week_2_data_ingestion/
│   │   │   ├── airflow/
│   │   │   │   ├── dags/
│   │   │   │   │   └── data_ingestion_gcs_dag.py
│   │   │   │   ├── dags_local/
│   │   │   │   │   ├── data_ingestion_local.py
│   │   │   │   │   └── ingest_script.py
│   │   │   │   ├── docs/
│   │   │   │   │   ├── 1_concepts.md
│   │   │   │   │   ├── arch-diag-airflow.png
│   │   │   │   │   └── gcs_ingestion_dag.png
│   │   │   │   ├── extras/
│   │   │   │   │   ├── data_ingestion_gcs_dag_ex2.py
│   │   │   │   │   └── web_to_gcs.sh
│   │   │   │   ├── scripts/
│   │   │   │   │   └── entrypoint.sh
│   │   │   │   ├── .env_example
│   │   │   │   ├── 1_setup_official.md
│   │   │   │   ├── 2_setup_nofrills.md
│   │   │   │   ├── Dockerfile
│   │   │   │   ├── README.md
│   │   │   │   ├── docker-compose-nofrills.yml
│   │   │   │   ├── docker-compose.yaml
│   │   │   │   ├── docker-compose_2.3.4.yaml
│   │   │   │   └── requirements.txt
│   │   │   ├── homework/
│   │   │   │   ├── homework.md
│   │   │   │   └── solution.py
│   │   │   ├── transfer_service/
│   │   │   │   └── README.md
│   │   │   └── README.md
│   │   ├── week_3_data_warehouse/
│   │   │   └── airflow/
│   │   │       ├── dags/
│   │   │       │   └── gcs_to_bq_dag.py
│   │   │       ├── docs/
│   │   │       │   ├── gcs_2_bq_dag_graph_view.png
│   │   │       │   └── gcs_2_bq_dag_tree_view.png
│   │   │       ├── scripts/
│   │   │       │   └── entrypoint.sh
│   │   │       ├── .env_example
│   │   │       ├── 1_setup_official.md
│   │   │       ├── 2_setup_nofrills.md
│   │   │       ├── README.md
│   │   │       ├── docker-compose-nofrills.yml
│   │   │       └── docker-compose.yaml
│   │   ├── week_5_batch_processing/
│   │   │   └── homework.md
│   │   ├── week_6_stream_processing/
│   │   │   └── homework.md
│   │   ├── README.md
│   │   └── project.md
│   ├── 2023/
│   │   ├── week_1_docker_sql/
│   │   │   └── homework.md
│   │   ├── week_1_terraform/
│   │   │   └── homework.md
│   │   ├── week_2_workflow_orchestration/
│   │   │   ├── README.md
│   │   │   └── homework.md
│   │   ├── week_3_data_warehouse/
│   │   │   └── homework.md
│   │   ├── week_4_analytics_engineering/
│   │   │   └── homework.md
│   │   ├── week_5_batch_processing/
│   │   │   └── homework.md
│   │   ├── week_6_stream_processing/
│   │   │   ├── client.properties
│   │   │   ├── homework.md
│   │   │   ├── producer_confluent.py
│   │   │   ├── settings.py
│   │   │   ├── spark-submit.sh
│   │   │   └── streaming_confluent.py
│   │   ├── workshops/
│   │   │   └── piperider.md
│   │   ├── README.md
│   │   ├── leaderboard.md
│   │   └── project.md
│   ├── 2024/
│   │   ├── 01-docker-terraform/
│   │   │   ├── homework.md
│   │   │   └── solutions.md
│   │   ├── 02-workflow-orchestration/
│   │   │   ├── README.md
│   │   │   └── homework.md
│   │   ├── 03-data-warehouse/
│   │   │   └── homework.md
│   │   ├── 04-analytics-engineering/
│   │   │   └── homework.md
│   │   ├── 05-batch/
│   │   │   └── homework.md
│   │   ├── 06-streaming/
│   │   │   ├── docker-compose.yml
│   │   │   └── homework.md
│   │   ├── workshops/
│   │   │   ├── dlt_resources/
│   │   │   │   ├── data_ingestion_workshop.md
│   │   │   │   ├── homework_solution.ipynb
│   │   │   │   ├── homework_starter.ipynb
│   │   │   │   ├── incremental_loading.png
│   │   │   │   └── workshop.ipynb
│   │   │   ├── dlt.md
│   │   │   └── rising-wave.md
│   │   ├── README.md
│   │   ├── leaderboard.md
│   │   └── project.md
│   ├── 2025/
│   │   ├── 01-docker-terraform/
│   │   │   └── homework.md
│   │   ├── 02-workflow-orchestration/
│   │   │   ├── flows/
│   │   │   │   ├── 01_getting_started_data_pipeline.yaml
│   │   │   │   ├── 02_postgres_taxi.yaml
│   │   │   │   ├── 02_postgres_taxi_scheduled.yaml
│   │   │   │   ├── 03_postgres_dbt.yaml
│   │   │   │   ├── 04_gcp_kv.yaml
│   │   │   │   ├── 05_gcp_setup.yaml
│   │   │   │   ├── 06_gcp_taxi.yaml
│   │   │   │   ├── 06_gcp_taxi_scheduled.yaml
│   │   │   │   └── 07_gcp_dbt.yaml
│   │   │   ├── images/
│   │   │   │   └── homework.png
│   │   │   ├── README.md
│   │   │   └── homework.md
│   │   ├── 03-data-warehouse/
│   │   │   ├── DLT_upload_to_GCP.ipynb
│   │   │   ├── homework.md
│   │   │   └── load_yellow_taxi_data.py
│   │   ├── 04-analytics-engineering/
│   │   │   ├── homework.md
│   │   │   └── homework_q2.png
│   │   ├── 05-batch/
│   │   │   └── homework.md
│   │   ├── 06-streaming/
│   │   │   ├── homework/
│   │   │   │   └── homework.ipynb
│   │   │   └── homework.md
│   │   ├── workshops/
│   │   │   ├── dlt/
│   │   │   │   ├── img/
│   │   │   │   │   ├── Rest_API.png
│   │   │   │   │   ├── dlt.png
│   │   │   │   │   └── pipes.jpg
│   │   │   │   ├── README.md
│   │   │   │   ├── data_ingestion_workshop.md
│   │   │   │   └── dlt_homework.md
│   │   │   └── dynamic_load_dlt.py
│   │   ├── README.md
│   │   └── project.md
│   └── 2026/
│       ├── 01-docker-terraform/
│       │   └── homework.md
│       ├── 02-workflow-orchestration/
│       │   └── homework.md
│       ├── 03-data-warehouse/
│       │   ├── DLT_upload_to_GCP.ipynb
│       │   ├── homework.md
│       │   └── load_yellow_taxi_data.py
│       ├── 04-analytics-engineering/
│       │   └── homework.md
│       ├── 05-data-platforms/
│       │   └── homework.md
│       ├── 06-batch/
│       │   └── homework.md
│       ├── 07-streaming/
│       │   └── homework.md
│       ├── workshops/
│       │   ├── dlt/
│       │   │   ├── images/
│       │   │   │   └── etl_diagram.png
│       │   │   ├── README.md
│       │   │   ├── analysis.py
│       │   │   ├── dlt_Pipeline_Overview.ipynb
│       │   │   ├── dlt_homework.md
│       │   │   ├── open_library_pipeline.py
│       │   │   └── pyproject.toml
│       │   └── dlt.md
│       ├── README.md
│       └── project.md
├── images/
│   ├── architecture/
│   │   ├── arch_v3_workshops.jpg
│   │   ├── arch_v4_workshops.jpg
│   │   ├── arch_v5_workshops.png
│   │   └── photo1700757552.jpeg
│   ├── aws/
│   │   └── iam.png
│   ├── bruin.svg
│   ├── dlthub.png
│   ├── kestra.svg
│   ├── mage.svg
│   ├── piperider.png
│   └── rising-wave.png
├── projects/
│   ├── README.md
│   └── datasets.md
├── .gitignore
├── README.md
├── Week01_Docker_Terraform.html
├── Week05_Dimensional_Modeling.html
├── after-sign-up.md
├── asking-questions.md
├── awesome-data-engineering.md
├── certificates.md
├── learning-in-public.md
├── senior_de_learning_roadmap.md
└── workshop-best-practices.md
```

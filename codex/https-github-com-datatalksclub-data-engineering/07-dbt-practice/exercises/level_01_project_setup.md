# Level 01 - Project Setup

## Goal

Run the local dbt project and understand its structure.

## Tasks

1. Start PostgreSQL with Docker Compose.
2. Install dbt dependencies.
3. Copy `profiles.yml.example` to your dbt profile path.
4. Run `dbt debug`.
5. Run `dbt parse`.
6. Run `dbt build`.

## Expected Output

- dbt connects successfully.
- raw sources are available in PostgreSQL schema `raw`.
- staging, intermediate, marts, snapshots schemas are created by dbt.

## Questions

- What is the difference between `source()` and `ref()`?
- Why does dbt need a profile?
- Where does dbt run compute?


# real-time-processing-pipeline

![Project Directory Structure](./pictures/architecture.svg)
A self‑contained data platform stack orchestrated via Docker Compose, including:

* **SQL Server** (MSSQL) as source
* **Kafka** & **Confluent Control Center**
* **Debezium Connect** for CDC ingestion into Kafka
* **Debezium UI** for connector management
* **Flink** for real-time processing
* **PostgreSQL** (Airflow metadata & DWH)
* **Airflow** (CeleryExecutor) for orchestration
* **Redis** for Celery broker & result backend



---

## Prerequisites

* Docker Engine ≥ 24.x
* Docker Compose plugin or standalone (`docker compose` CLI)
* At least **4 GB RAM** and **2 CPUs** available

> ⚠️ The `airflow-init` service checks resources at startup and will warn if your host is under‑provisioned.

---

## Getting Started

1. **Clone this repo**

   ```bash
   git clone https://github.com/hasancatalgol/iceflow-pipeline.git
   cd iceflow-pipeline
   ```

2. **Configure environment**
   Copy `.env.example` to `.env` and adjust any credentials or ports as needed:

   ```bash
   cp .env.example .env
   ```

3. **(Optional) Customize Airflow image**
   By default, this stack builds a custom Airflow image from `docker/Airflow/Dockerfile.airflow`.
   To use the official image instead, comment out the `build:` section under the `x-airflow-common` definition, and uncomment:

   ```yaml
   image: apache/airflow:3.0.0
   ```

4. **Start the stack**

   ```bash
   docker compose up -d --remove-orphans --wait
   ```

   Services are grouped by Docker Compose profiles.

   * `airflow`: orchestration & metadata (`airflow-apiserver`, `scheduler`, `worker`, etc.)
   * `db`: `postgres` (DWH & metadata) and `mssql-server`
   * `kafka`: Kafka, Connect, Debezium UI, Control Center

   You can launch a subset by specifying profiles:

   ```bash
   docker compose --profile airflow up -d
   ```

---

## Accessing the Services

| Service                     | URL / Port                                                         |
| --------------------------- | ------------------------------------------------------------------ |
| Airflow UI                  | [http://localhost:8080](http://localhost:8080)                     |
| Airflow API (execution)     | [http://localhost:8080/execution](http://localhost:8080/execution) |
| Redis CLI                   | redis\://localhost:6379                                            |
| PostgreSQL DWH (sipay)      | localhost:5433                                                     |
| PostgreSQL Airflow metadata | localhost:5432                                                     |
| SQL Server (MSSQL)          | localhost:1433                                                     |
| Kafka Connect REST          | [http://localhost:8083](http://localhost:8083)                     |
| Debezium UI                 | [http://localhost:8089](http://localhost:8089)                     |
| Kafka (broker)              | localhost:9092                                                     |
| Control Center              | [http://localhost:9021](http://localhost:9021)                     |

Default credentials are documented in each section of `docker-compose.yml`.

---

## Managing the Stack

* **View logs**

  ```bash
  docker compose logs -f <service_name>
  ```

* **Run one‑off Airflow CLI**

  ```bash
  docker compose run --rm airflow-cli dags list
  ```

* **Stop & remove containers**

  ```bash
  docker compose down --volumes
  ```

* **Rebuild Airflow image**

  ```bash
  docker compose build airflow-apiserver
  ```

---

## Custom DAGs, Connectors & Init Scripts

* Place your Airflow DAGs under `./dags`.
* Airflow `plugins` directory is mounted from `./plugins`.
* Initialize DWH schema & sample data via SQL or Python scripts in `./init/dwh`.
* Kafka Connect JSON configurations live in `docker/Connect/connectors`.

---

## Cleanup & Data Persistence

* **Volumes**:

  * `postgres-db-volume` for Airflow metadata
  * `dwh_data2` for DWH data
  * `mssql-data` for SQL Server

* To purge all data:

  ```bash
  docker compose down --volumes --remove-orphans
  ```

---

## Notes & Troubleshooting

* Healthchecks guard dependency ordering but can be tuned via `retries` and `start_period`.
* If you run into permission errors on Linux, set `AIRFLOW_UID` in `.env` to your UID.
* For large seed files, consider using Git LFS or external storage instead of mounting directly.

---


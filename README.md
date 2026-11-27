# DBT docker image

a [dbt-core](https://github.com/dbt-labs/dbt-core) 2.0 (release candidate) docker image targeting DuckDB, with an entrypoint that :  

1. clone the ${GIT_REPO} with the ${GIT_TOKEN} 

2. eval the profiles.yaml to replace the ${...} by given value

3. run the user CMD

## 1) Use locally 

### 1.1) create .env file with a github token (for local test)

```shell
~/REPO/raphaelauv/dbt-docker$ cat <<EOT >> .env
GITHUB_TOKEN=REPLACE_ME_WITH_YOUR_GITHUB_TOKEN
EOT
```

### 1.2) Build and run the container
```shell 
~/REPO/raphaelauv/dbt-docker$ docker compose build
~/REPO/raphaelauv/dbt-docker$ docker compose up dbt
```

dbt writes to the DuckDB file `/data/dbt.duckdb` (env `DUCKDB_PATH`), stored in the `duckdb-data` volume.

### 1.3) Query the result with the DuckDB CLI

DuckDB allows only one process to write a database file, so run it once dbt has finished:

```shell
~/REPO/raphaelauv/dbt-docker$ docker compose run --rm duckdb
```

Profile env vars: `DUCKDB_PATH` (default `/data/dbt.duckdb`), `SCHEMA` (default `main`), `THREADS` (default `1`).

## 2) Use with Airflow ( Kubernetes )

```python
"""
# Dag goal ...
"""
from pendulum import today
from airflow import DAG
from airflow.kubernetes.secret import Secret
from airflow.providers.cncf.kubernetes.operators.kubernetes_pod import KubernetesPodOperator


dag = DAG("dbt_test",
          schedule_interval="@daily",
          start_date=today("UTC").add(days=-1),
          tags=['dbt'],
          doc_md=__doc__,
          catchup=False,
          max_active_runs=1
          )

secret_git_token = Secret(
    deploy_type='env',
    deploy_target='GIT_TOKEN',
    secret="REPO-github-token",
    key='git_token')

with dag:
    KubernetesPodOperator(
        task_id="dbt_test",
        name="airflow-dags.dbt",
        namespace="default",
        arguments=["dbt", "run", "--profiles-dir", "."],
        env_vars={  # noqa
            "GIT_REPO": "user_name/MY_REPO.git",
            # point to a persistent volume
            "DUCKDB_PATH": "/data/dbt.duckdb",
        },
        secrets=[secret_git_token],
        is_delete_operator_pod=True,
        deferrable=True,
        image="dbt:0.1")

```

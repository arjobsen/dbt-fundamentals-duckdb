# dbt Fundamentals with DuckDB


## Chapter 03. Set Up dbt
1. Create a new project folder: `mkdir dbt-fundamentals-duckdb`
1. Create a Python virtual enviroment: `python -m venv venv`
1. Activate the Python virtual envirmont: `source venv/Scripts/activate`
1. Install dbt, DuckDB and the DuckDB plugin for dbt: `pip install dbt duckdb dbt-duckdb`
1. Run `dbt init`

### Set up the data
In the official dbt Fundamentals course they use 2 databases:
* `raw` for the raw data
* `analytics` for the transformed data - the dbt output

1. Make sure your present working directory is **dbt-fundamentals-duckdb**
1. Create a new folder: `mkdir data`
1. And enter that: `cd data`
1. Open a Python (`python`) or IPython (`ipython`) prompt


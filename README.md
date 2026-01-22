> You can also use [this repository](https://github.com/arjobsen/dbt-fundamentals-postgresql) to follow dbt Fundamentals with PostgreSQL running in a Docker container!

# dbt Fundamentals with DuckDB
This guide describes how to follow [dbt Fundamentals](https://learn.getdbt.com/courses/dbt-fundamentals) using a local dbt Core install and a local DuckDB database.

The steps **do not** represent a complete copy of the course. It only describes the steps where you should do something _different_ than the official course.

## Chapter 01. Welcome to dbt Fundamentals
No changes for this chapter. Just follow the course.

## Chapter 02. Analytics Development Lifecycle
No changes for this chapter. Just follow the course.

## Chapter 03. Set Up dbt
In the chapter you are asked to register for a dbt trial account (to use dbt Studio online) and to register for a data platform (Snowflake, BigQuery or Databricks). We are **not** going to do that. Instead, we install dbt Core and DuckDB using Python.

### Install dbt and DuckDB in a Python virtual environment
The commands shown in the guide assume you are using either bash on Linux or [Git Bash](https://gitforwindows.org/) on Windows and you have [Python](https://www.python.org/) installed.
1. Open a terminal or Git Bash
1. Create a new folder named **dbt-fundamentals-duckdb**: `mkdir dbt-fundamentals-duckdb`
1. Change into that directory: `cd dbt-fundamentals-duckdb`
1. Create a [Python virtual environment](https://docs.python.org/3/library/venv.html): `python -m venv venv`
1. Activate that virtual environment
    * Linux: `source venv/bin/activate`
    * Windows (Git Bash): `source venv/Scripts/activate`
1. Test with `which pip` that pip points to the executable in your venv folder
1. Install dbt, DuckDB and the DuckDB plugin for dbt: `pip install dbt duckdb dbt-duckdb`
1. Test with `dbt --version` that dbt-core and the dbt-postgres plugin is installed correctly

### Initialize the dbt project folder
1. Make sure you are in your **dbt-fundamentals-duckdb** folder and your venv is activated
1. Run `dbt init`
1. Enter a name for your project: `jaffle_shop`
1. Which database would you like to use? Enter the number corresponding to duckdb: (`1` if you didn't install any other dbt plugins)

dbt added a new file in **~/.dbt/profiles.yml** with the DuckDB connection details but we need to make some changes there.
1. Open the file **~/.dbt/profiles.yml** in a text editor
1. Change the database name to `../data/analytics.duckdb`
1. Add the schema name `dbt_user`
1. See **profiles.yml** in this repository for an example

### Load the raw data into DuckDB
In the official dbt Fundamentals course they use 2 databases:
* `raw` for the raw data
* `analytics` for the transformed data - the dbt output

DuckDB stores a database as a file. One file is one database. It is possible to attach multiple database files, but for this guide we make it easy for ourselves and work with just 1 database file: `analytics.duckdb`. We'll distinguish between raw data and transformed data using the schema name.

1. Make sure you're in **dbt-fundamentals-duckdb**
1. Create a new folder: `mkdir data`
1. And enter that: `cd data`
1. Open a Python (`python`) or IPython (`ipython`) prompt
1. Run the following code
    ```python
    import duckdb
    
    con = duckdb.connect('analytics.duckdb')
    
    q = """
        -- Create schemas
        create schema raw_jaffle_shop;
        create schema raw_stripe;

        -- Customers table
        create table raw_jaffle_shop.customers (
            id integer,
            first_name varchar,
            last_name varchar
        );
        copy raw_jaffle_shop.customers (id, first_name, last_name)
        from 's3://dbt-tutorial-public/jaffle_shop_customers.csv';

        -- Orders table
        create table raw_jaffle_shop.orders (
            id integer,
            user_id integer,
            order_date date,
            status varchar,
            _etl_loaded_at timestamp default current_timestamp
        );
        copy raw_jaffle_shop.orders (id, user_id, order_date, status)
        from 's3://dbt-tutorial-public/jaffle_shop_orders.csv';

        -- Payment table
        create table raw_stripe.payment (
            id integer,
            orderid integer,
            paymentmethod varchar,
            status varchar,
            amount integer,
            created date,
            _batched_at timestamp default current_timestamp
        );
        copy raw_stripe.payment (id, orderid, paymentmethod, status, amount, created)
        from 's3://dbt-tutorial-public/stripe_payments.csv';
    """
    con.sql(q)
    
    con.sql("select count(*) from raw_jaffle_shop.customers")   # The result should be 100
    con.sql("select count(*) from raw_jaffle_shop.orders")      # The result should be 99
    con.sql("select count(*) from raw_stripe.payments")         # The result should be 120
    
    con.close()
    ```
1. Now you have added a DuckDB database file **analytics.duckdb** and loaded the data into 3 tables
1. Exit the Python or IPython prompt with `exit`

## Chapter 04. Models
Most of the videos in this chapter you can just follow along. For the videos which are listed below, you need to make some exceptions.

### Changes for video: Build Your First Model
In the **customers.sql** file replace the database.schema name `raw.jaffle_shop` with `analytics.raw_jaffle_shop` on line 8 and line 20.

_Note:_ They show the option to Preview CTE. This is a capability of dbt Fusion. We installed dbt Core, so unfortunately we don't have that option.

### Changes for Practice and Exemplar
Also here, replace the database and schema with `analytics.raw_jaffle_shop`. And do the same for `analytics.raw_stripe`.

## Chapter 05. Sources
### Changes for video: Configure Sources
When adding **_src_jaffle_shop.yml**, fill in the database `analytics` and the schema `raw_jaffle_shop`.

### Changes for video: References Sources in Staging Models
In the video they show the SQL code which is compiled by dbt. You can use `dbt compile --select stg_jaffle_shop__customers`.

### Changes for video: Source Freshness
No changes for this chapter. Just follow the course.

## Chapter 06. Data Tests
No changes for this chapter. Just follow the course.

_Note:_ Throughout the dbt Fundamentals course, you see git commits are made once in a while. This is optional. Git is not covered in this guide.

## Chapter 07. Documentation
No changes for this chapter. Just follow the course.

Generate the documentation with `dbt docs generate`. And serve it with `dbt docs serve`. [Read more](https://docs.getdbt.com/reference/commands/cmd-docs) about that.

## Chapter 08. Deployment
Setting up deployment or scheduling jobs in Orchestration is not possible because we don't have a dbt Cloud account.

In your home directory (`~`) dbt has created a folder called **.dbt** with a file called **profiles.yml**. This [dbt profile](https://docs.getdbt.com/docs/core/connect-data-platform/profiles.yml) is filled in with the credentials you entered for `dbt init`. To add a new profile:
1. Open **~/.dbt/profiles.yml**
1. Write a new profile called `prod`
1. Use the same arguments as you find under `dev`, except for the schema, use `schema: analytics`
1. See the file **profiles.yml** in this repo for an example

To use the production deployment, add the `--target prod` argument to the dbt commands you've learned:
```
dbt seed --target prod
dbt source freshness --target prod
dbt build --target prod
dbt docs generate --target prod
```

# dbt Fundamentals with DuckDB


## Chapter 03. Set Up dbt
1. Create a new project folder: `mkdir dbt-fundamentals-duckdb`
1. Create a Python virtual environment: `python -m venv venv`
1. Activate the Python virtual envirmont: `source venv/Scripts/activate`
1. Install dbt, DuckDB and the DuckDB plugin for dbt: `pip install dbt duckdb dbt-duckdb`
1. Run `dbt init`
1. Enter a name for your project? `jaffle_shop`
1. Which database would you like to use? Choose the number which corresponds to duckdb (`1` if you didn't install any other dbt database plugins)

dbt added a **profiles.yml** file in ~/.dbt with the DuckDB connection details but we need to make some changes there.
1. Open the file **~/.dbt/profiles.yml** in a text editor
1. Change the database name to `../data/analytics.duckdb`
1. Add the schema name `dbt_user`

### Set up the data
In the official dbt Fundamentals course they use 2 databases:
* `raw` for the raw data
* `analytics` for the transformed data - the dbt output

DuckDB stores a database as a file. One file is one database. It is possible to attach multiple database, but for this guide we make it easy for ourselves and work with just 1 database file: `analytics.duckdb`. We'll distinguish between raw data and transformed data using the schema name.

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

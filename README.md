# Zomato AI Data Analytics

An end-to-end **data engineering and AI analytics project** built around Zomato
data. The project takes raw CSV datasets through a complete modern data
pipeline: files are stored in **AWS S3**, loaded into **Snowflake**, transformed
and tested with **dbt**, and orchestrated using **Apache Airflow running in
Docker**.

On top of the structured analytics layer, the project adds an **AI layer** for
customer-review analysis. Gemini is used to enrich reviews with **sentiment,
topic, and key-issue information**. These AI results are then transformed in
Snowflake using dbt to create analytical insights such as review counts,
average sentiment, ratings, and flagged issues.

The project also provides two natural-language AI applications. **Text-to-SQL**
allows users to ask questions about the Zomato warehouse in natural language
and converts those questions into SQL queries for Snowflake. A **RAG-based
chat application** retrieves relevant customer reviews using embeddings and
uses Gemini to generate answers based on the retrieved review context.

The complete flow is:

```text
Raw Zomato CSV Files
        ↓
      AWS S3
        ↓
Snowflake RAW Layer
        ↓
dbt Staging Layer
        ↓
dbt Marts / Analytics Layer
        ↓
     ┌───────────────────────────────┐
     │                               │
     ▼                               ▼
AI Review Enrichment             Text-to-SQL
     │                               │
     ▼                               ▼
Snowflake AI Tables             Snowflake
     │
     ▼
AI/dbt Analytics
     │
     ▼
RAG Embeddings
     │
     ▼
Streamlit RAG Chat
```

### What the Project Demonstrates

- Building a cloud-based **data warehouse pipeline** using S3 and Snowflake
- Designing **staging and mart layers** with dbt
- Applying **incremental models, snapshots, and data quality tests**
- Automating the pipeline with **Airflow DAGs**
- Creating a reproducible Airflow environment with **Docker**
- Using **Gemini LLMs** for structured review analysis
- Building **Text-to-SQL** for natural-language database querying
- Implementing **RAG** using review embeddings and retrieved context
- Combining traditional data engineering with **generative AI applications**

The result is a single pipeline that connects **data ingestion → transformation →
orchestration → AI enrichment → analytics → natural-language interaction**.

## Project Structure

``` text
Zomato-Ai Data Analytics/
│
├── ai/
│   ├── enrich_reviews.py
│   ├── rag_chat.py
│   ├── text_to_sql.py
│   └── .env
│
├── airflow/
│   ├── dags/
│   │   └── zomato_batch.py
│   ├── Dockerfile
│   ├── docker-compose.yaml
│   └── .env
│
├── zomato/
│   ├── models/
│   │   ├── staging/
│   │   └── marts/
│   ├── snapshots/
│   ├── seeds/
│   ├── macros/
│   ├── analyses/
│   ├── tests/
│   ├── dbt_project.yml
│   ├── profiles.yml
│   └── packages.yml
│
├── data/
│   └── *.csv
│
└── README.md
```

------------------------------------------------------------------------

## 1. Data Ingestion

The project starts with raw Zomato CSV datasets such as:

-   `food`
-   `menu`
-   `order_items`
-   `orders`
-   `restaurant`
-   `reviews`
-   `users`

The raw files are uploaded to an **AWS S3 bucket**.

Snowflake accesses the S3 data through an external storage integration
and stage.

``` text
CSV → S3 → Snowflake Stage → RAW tables
```

------------------------------------------------------------------------

## 2. Snowflake Data Warehouse

The main Snowflake database is:

``` text
ZOMATO
```

Important schemas:

  Schema        Purpose
  ------------- ------------------------------
  `RAW`         Raw ingested data
  `STAGING`     Cleaned and transformed data
  `MARTS`       Final analytics-ready tables
  `SNAPSHOTS`   Historical/SCD2 data
  `AI`          LLM-enriched review data

A Snowflake warehouse is used to execute SQL transformations and
queries.

------------------------------------------------------------------------

## 3. dbt Transformation

dbt transforms the raw Snowflake data through multiple layers:

``` text
RAW
 ↓
STAGING
 ↓
MARTS
```

### Staging

The staging layer performs tasks such as:

-   Renaming columns
-   Cleaning data types
-   Standardizing fields
-   Preparing raw data for analytics

### Marts

The marts layer contains business-ready models such as:

-   `dim_date`
-   `dim_customer`
-   `dim_restaurant`
-   `fct_orders`

The fact and dimension models follow a dimensional/star-schema style.

`fct_orders` is configured as an **incremental model**, so new/changed
records can be processed without rebuilding the entire table.

### dbt Tests

dbt tests are used to check data quality, including:

-   `unique`
-   `not_null`
-   Referential relationships
-   Source validation

Run dbt with:

``` bash
dbt build
```

------------------------------------------------------------------------

## 4. Airflow + Docker

Apache Airflow is used to automate the complete pipeline.

Airflow runs inside Docker containers using `docker-compose.yaml`.

The main DAG coordinates the pipeline approximately as:

``` text
Reload RAW
    ↓
dbt Build
    ↓
AI Review Enrichment
    ↓
dbt AI Models
```

Important Airflow tasks include:

-   Loading/reloading raw Snowflake data
-   Running dbt transformations
-   Running the review enrichment Python script
-   Building AI-related dbt models

Docker makes the Airflow environment reproducible and avoids installing
all Airflow dependencies directly on Windows.

Start the Airflow environment from the `airflow` directory:

``` powershell
docker compose up -d
```

------------------------------------------------------------------------

## 5. AI Review Enrichment

Customer reviews are enriched using **Google Gemini**.

The script:

``` text
ai/enrich_reviews.py
```

reads reviews from Snowflake and sends them to the Gemini model.

Each review is classified into information such as:

-   **Topic**
    -   food quality
    -   delivery
    -   pricing
    -   service
    -   packaging
    -   other
-   **Sentiment label**
-   **Sentiment score**
-   **Key issue**

The enriched results are stored in Snowflake under the `AI` schema.

Example flow:

``` text
STG_REVIEWS
     ↓
Gemini
     ↓
Review enrichment
     ↓
AI.REVIEW_ENRICHED
```

API keys and database credentials are kept in `.env` files and are not
committed to Git.

------------------------------------------------------------------------

## 6. AI Analytics with dbt

The AI-enriched review table is exposed to dbt as a source.

Example:

``` text
AI.REVIEW_ENRICHED
        +
STAGING.STG_REVIEWS
        ↓
dbt AI model
```

The resulting models can calculate metrics such as:

-   Number of reviews by topic
-   Average sentiment score
-   Average star rating
-   Number of flagged issues
-   City-level review insights

AI models are tagged with:

``` yaml
tags: ['ai']
```

They can therefore be built separately:

``` bash
dbt build --select tag:ai
```

------------------------------------------------------------------------

## 7. Text-to-SQL

`ai/text_to_sql.py` converts natural-language questions into SQL using Gemini,
executes the SQL in Snowflake, and displays the result.

```text
Question → Gemini → SQL → Snowflake → Result
```

---

## 8. RAG Chat Application

The project also includes a Retrieval-Augmented Generation (RAG)
application:

``` text
ai/rag_chat.py
```

The application uses:

-   **Streamlit** -- user interface
-   **Gemini Embeddings** -- convert reviews into vectors
-   **Snowflake** -- review data
-   **Gemini** -- generate answers

### RAG Flow

``` text
User Question
     ↓
Generate Query Embedding
     ↓
Find Similar Reviews
     ↓
Retrieve Top-K Reviews
     ↓
Send Context + Question to Gemini
     ↓
Generate Answer
```

A local Parquet file is used to cache review embeddings so that
embeddings do not need to be regenerated every time the application
starts.

Run the application with:

``` bash
streamlit run rag_chat.py
```

------------------------------------------------------------------------

## 9. Environment Variables

Sensitive information should be stored in `.env` files rather than
source code.

Typical variables include:

``` env
SNOWFLAKE_ACCOUNT=...
SNOWFLAKE_USER=...
SNOWFLAKE_PASSWORD=...
SNOWFLAKE_DATABASE=ZOMATO
SNOWFLAKE_SCHEMA=AI
SNOWFLAKE_WAREHOUSE=...
GEMINI_API_KEY=...
```

Add `.env` to `.gitignore`:

``` gitignore
.env
creds/
logs/
```

Never commit API keys, passwords, or cloud credentials to GitHub.

------------------------------------------------------------------------

## 10. Running the Complete Pipeline

### Step 1 --- Start Airflow

``` powershell
cd airflow
docker compose up -d
```

### Step 2 --- Run the Airflow DAG

Trigger the Zomato batch DAG from the Airflow UI.

The DAG performs:

``` text
Raw Load
→ dbt Transformation
→ Gemini Review Enrichment
→ dbt AI Transformation
```

### Step 3 --- Run RAG Chat

From the `ai` directory:

``` bash
streamlit run rag_chat.py
```

Then open the Streamlit URL shown in the terminal.

------------------------------------------------------------------------

## Key Technologies

  Technology   Role
  ------------ ---------------------------------
  Python       Data processing and AI scripts
  AWS S3       Raw data storage
  Snowflake    Data warehouse
  dbt          SQL transformations and testing
  Airflow      Pipeline orchestration
  Docker       Airflow containerization
  Gemini       LLM and embeddings
  Streamlit    RAG chat interface
  Git/GitHub   Version control

------------------------------------------------------------------------

## Project Outcome

This project demonstrates a complete modern data and AI pipeline:

**Data Ingestion → Cloud Warehouse → Transformation → Orchestration →
LLM Enrichment → Analytics → RAG Application**

It combines traditional data engineering with modern AI capabilities to
turn raw Zomato data and customer reviews into actionable analytical
insights.

---

## Author

**Ankesh Parashar**  
Mechanical Engineering, NIT Patna

### Skills
**Python · SQL · Snowflake · dbt · Airflow · Docker · AWS S3 · Git ·
Pandas · NumPy · Scikit-learn · Generative AI · RAG**

### Interests
**Data Engineering · Data Analytics · Machine Learning · Generative AI ·
Problem Solving · Sketching & Painting**

- GitHub: [AnkeshParashar](https://github.com/AnkeshParashar)

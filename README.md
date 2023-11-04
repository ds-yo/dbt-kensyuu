# 本リポジトリのディレクトリ構造
```
├── .github
│   └── workflows
│       ├── dev_ci.yml # CI用
│       └── dev_cicd.yml # CI/CD用
├── 0_work # 演習用
├── 99_answer # 回答見本
│   └── chura_training
│       ├── .sqlfluff
│       ├── .sqlfluffignore
│       ├── analyses
│       ├── dbt_project.yml
│       ├── macros
│       │   └── month_format.sql
│       ├── models
│       │   ├── ci_cd_example # CI/CD用
│       │   │   └── customer.sql
│       │   ├── example # CI演習用
│       │   │   ├── customer_age_ci.sql
│       │   │   └── shop_sales_mon_ci.sql
│       │   ├── sample # CI見本用
│       │   │   ├── my_first_dbt_model.sql
│       │   │   └── my_second_dbt_model.sql
│       │   └── staging # dbt基礎演習用
│       │       ├── _sources.yml
│       │       ├── customer_age.sql
│       │       ├── month_calendar.sql
│       │       └── shop_sales_mon.sql
│       ├── packages.yml
│       ├── profiles.yml
│       ├── seeds # PUBLICスキーマに投入するデータ(講師が事前に投入すること)
│       │   ├── customers.csv
│       │   ├── orders
│       │   │   └── orders.csv
│       │   └── shops.csv
│       ├── snapshots
│       └── tests
├── README.md
└── requirements.txt
```

# 講師の方へ

## 研修の前に必ず実施してください

### リポジトリの作成
- 本リポジトリをテンプレートとしてpj用のリポジトリを作成してください
    - [Use this template]を選択->[Create a new repository]を選択->[Include all branches]にはチェックを入れずに、pj用のリポジトリに設定な項目を入力して作成(mainブランチのみテンプレートとして利用すること)
- CI/CD演習に利用するために、mainブランチからinitブランチを作成し、initブランチから.github/workflowsディレクトリを削除してください
- CI/CDを実行するために、environments(secrets,variables)の登録が必要なので、作成したリポジトリで受講生に対してadmin権限を与えてください

### Snowflake上でDB環境を構築（ロール、データベース、ウェアハウス、ユーザを作成）
- ロール,データベース,ウェアハウスを作成（研修時にPJ単位で共通して使うオブジェクトを作成）
    - SQLの例（CHURAの箇所は各PJ名に変更し実行してください）

```sql
CREATE ROLE CHURA_DBT_TRAINING_ROLE;

GRANT ROLE CHURA_DBT_TRAINING_ROLE
    TO ROLE SYSADMIN;

CREATE DATABASE CHURA_DBT_TRAINING_DB;

CREATE WAREHOUSE CHURA_DBT_TRAINING_WH
    WITH WAREHOUSE_SIZE = 'XSMALL'
    WAREHOUSE_TYPE = 'STANDARD'
    AUTO_SUSPEND = 60
    AUTO_RESUME = TRUE
    MIN_CLUSTER_COUNT = 1
    MAX_CLUSTER_COUNT = 1;

GRANT USAGE
    ON WAREHOUSE CHURA_DBT_TRAINING_WH
    TO ROLE CHURA_DBT_TRAINING_ROLE;

GRANT ALL
    ON DATABASE CHURA_DBT_TRAINING_DB
    TO ROLE CHURA_DBT_TRAINING_ROLE;

GRANT ALL
    ON SCHEMA CHURA_DBT_TRAINING_DB.PUBLIC
    TO ROLE CHURA_DBT_TRAINING_ROLE
```
- ユーザを作成（研修を受ける受講生ごとに1つずつ作成）
    - SQLの例（CHURAの箇所は各PJ名に変更し、対象のユーザ名を変更して実行してください）

```sql
-- CHURA_DBT_USER_DKANESHIRO
CREATE USER CHURA_DBT_USER_DKANESHIRO PASSWORD='5c$i/Q%' DEFAULT_ROLE = CHURA_DBT_TRAINING_ROLE MUST_CHANGE_PASSWORD = TRUE;
GRANT ROLE CHURA_DBT_TRAINING_ROLE TO USER CHURA_DBT_USER_DKANESHIRO;

-- CHURA_DBT_USER_HAWASHIMA
CREATE USER CHURA_DBT_USER_HAWASHIMA PASSWORD='K4A,f+D' DEFAULT_ROLE = CHURA_DBT_TRAINING_ROLE MUST_CHANGE_PASSWORD = TRUE;
GRANT ROLE CHURA_DBT_TRAINING_ROLE TO USER CHURA_DBT_USER_HAWASHIMA;
```
### ダミーデータの挿入
研修実施の前に、99_answer/chura_trainingにて、PUBLICスキーマを対象に以下を実行してダミーデータを挿入してください
- dbtコマンドを利用する方法については、[Python実行環境の構築](#python実行環境の構築)を参考にしてください
- 環境変数の登録については、[環境変数設定](#環境変数設定)を参考にしてください
```bash
# 前提：他の環境変数（認証情報）は登録済みとする
export DBT_SCHEMA=PUBLIC
# パッケージをインストール
dbt deps
# ダミーデータを挿入
dbt seed
```

## 本研修の研修資料リンク（スライド、実行確認方法が格納されてます。あくまでテンプレートのため、案件用にカスタマイズして研修を実施してください）
https://datumstudio.app.box.com/folder/233303527146
## 問い合わせ先
不明な点があれば、ちゅらデータの兼城大または淡島英輝に連絡してください

# 構築手順

## 環境
- DB: `Snowflake` (研修に応じたSnowflakeアカウントを利用してください) 
- GitHubリポジトリ名: `pj-xxx-dbt-training` (pj用のリポジトリを作成してください)
- dbt core: `1.6.3`
- Python: `3.9.17`

## Python実行環境の構築
1. `python3 -m venv venv`
    - 仮想環境のvenvを作成
1. `source venv/bin/activate`
    - venvをアクティベート
1. `pip install --upgrade pip`
    - pipのバージョンを更新
1. `pip install -r requirements.txt`
    - 必要なモジュールをインストール

## 環境変数設定

| 変数名 | 設定値 |
| ------ | ----- |
| SNOWFLAKE_ACCOUNT | 研修に使うsnowflakeアカウントを設定 (例として `hoge.ap-northeast-1.aws`を利用) |
| DBT_DB | 研修に使うsnowflakeデータベースを設定 (例として`DBT_TRAINING_DB`を利用) |
| DBT_SNOWFLAKE_ROLE | 研修に使うsnowflakeロールを設定(例として`DBT_TRAINING_ROLE`を利用) |
| DBT_SCHEMA | 研修に使うsnowflakeスキーマを設定 (例として`DBT_TRAINING_SCHEMA`を利用)|
| SNOWSQL_USER | 研修に使うsnowflakeユーザ(研修時は個人のユーザを利用) |
| SNOWSQL_PASSWORD | 研修に使うsnowflakeユーザのパスワード |
| DBT_SNOWFLAKE_WH | DBTで研修に使うsnowflakeのWarehouse(例として`DBT_TRAINING_WH`を利用)|

### ローカルで実行する場合
- profiles.ymlで利用する環境変数をexport(利用環境に応じてexportすること)
    ```bash
    export SNOWFLAKE_ACCOUNT=hoge.ap-northeast-1.aws # Snowflakeアカウントを入力
    export DBT_DB=CHURA_DBT_TRAINING_DB # SnowflakeのDBを入力（研修で1つの共通DBを使うことを想定）
    export DBT_SNOWFLAKE_ROLE=CHURA_DBT_TRAINING_ROLE # SnowflakeのRoleを入力（研修で1つの共通Roleを使うことを想定）
    export DBT_SCHEMA=DEV_<user name> # SnowflakeのSchemaを入力（研修では受講生それぞれ異なるSchemaを使うことを想定）
    export SNOWSQL_USER=CHURA_DBT_USER_<user name> # Snowflakeのユーザを入力（研修では受講生それぞれ異なるユーザを使うことを想定）
    export SNOWSQL_PWD=<input your snowflake password> # Snowflakeのユーザに対するパスワードを入力（研修では受講生それぞれ異なるユーザとそれに対応するパスワードを使うことを想定）
    export DBT_SNOWFLAKE_WH=CHURA_DBT_TRAINING_WH # SnowflakeのDataWarehouseを入力（研修では1つの共通DataWarehouseを使うことを想定）
    ```


# GitHubActionsによるCI/CD実行時の設定
## シークレットや環境変数を登録
1. [Settings]->[Environments]->[New environment]をクリック
2. Nameを'<GitHubAccountName>-env'と名づける
- 例：d-kaneshiro-env
3. Environment secretsに、以下を設定
- Name：'SNOWFLAKE_ACCOUNT'と入力
    - Value：利用するSnowflakeAccountを入力
- Name：'SNOWSQL_PWD'と入力
    - Value：利用するSnowflakeパスワードを入力
- Name：'SNOWSQL_USER'と入力
    - Value：利用するSnowflakeユーザを入力
4. Environment variablesに、以下を設定
- Name：'DBT_DB'と入力
    - Value：利用するSnowflakeDBを入力
- Name：'DBT_SCHEMA'と入力
    - Value：利用するSnowflakeスキーマを入力
- Name：'DBT_SNOWFLAKE_ROLE'と入力
    - Value：利用するSnowflakeロールを入力
- Name：'DBT_SNOWFLAKE_WH'と入力
    - Value：利用するSnowflakeのWarehouseを入力

# GitHubActionsによるCI/CDが実行されるタイミングおよび実行手順
- CI(Lintチェック)
    - 自動
        - main以外のブランチへのPR作成時またはpush時
- CI/CD (Lintチェックおよびdbt run)
    - 自動
        - mainブランチにマージされた時
    - 手動
        - [Actions] -> [[CI/CD] for development] -> [Run workflow] -> 開発環境にデプロイするBranchを選択
# Tips
## SQLFluff
1. `sqlfluff lint ./models/`
    - modelsディレクトリにあるSQLのLintチェックが実行される
        - 99_answer/chura_training/配下のexampleおよびsampleはスタイルルール違反のエラーが出る点に注意

# 参考資料
- sqlfluff
https://github.com/sqlfluff/sqlfluff

- dbt style guide (SQL)
https://docs.getdbt.com/guides/best-practices/how-we-style/2-how-we-style-our-sql

- dbtプロジェクトにSQLFluffを導入する
https://tech.dely.jp/entry/2023/07/14/114205

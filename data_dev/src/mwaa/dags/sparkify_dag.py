from datetime import datetime, timedelta
import pendulum
import os
from airflow.decorators import dag
from airflow.operators.dummy_operator import DummyOperator
from operators.stage_redshift import StageToRedshiftOperator
from operators.load_fact import LoadFactOperator
from operators.load_dimension import LoadDimensionOperator
from operators.data_quality import DataQualityOperator
from operators.recreate_table import RecreateTableOperator
from helpers import sql_ddl_statements
from airflow.models import Variable
from helpers import sql_transformation_statements
from airflow.utils.task_group import TaskGroup

default_args = {
    "owner": "udacity",
    "start_date": "11-01-2018",
    "retries": 3,
    "retry_delay": timedelta(minutes=5),
    "depends_on_past": False,
    "schedule_interval": "@hourly",
    "email_on_failure": False,
    "email_on_retry": False,
    "end_date": "12-01-2018",
    "catchup": False
}

STAGING_EVENTS_TABLE_NAME="staging_events"
STAGING_SONGS_TABLE_NAME="staging_songs"
FACTS_SONGPLAYS_TABLE_NAME="songplays"
STAGING_EVENTS_S3_KEY="sparkify/log-data/{year}/{month}/"
STAGING_EVENTS_JSONPATH_S3_KEY="sparkify/log_json_path.json"
STAGING_SONGS_S3_KEY="sparkify/song-data/"
DIMENSION_SONGS_TABLE_NAME="songs"
DIMENSION_USERS_TABLE_NAME="users"
DIMENSION_ARTISTS_TABLE_NAME="artists"
DIMENSION_TIME_TABLE_NAME="time"
QUALITY_CHECK_JSON = os.path.abspath("./plugins/helpers/quality_rules.json")

@dag("sparkify-dag",
    default_args=default_args,
    max_active_runs=1,
    description='Load and transform data in Redshift with Airflow'
)
def final_project():

    start_operator = DummyOperator(task_id='Begin_execution')

    with TaskGroup("load_stage_tables") as load_stage_table_group:
      
        
        stage_events_to_redshift = StageToRedshiftOperator(
            task_id="Stage_events",
            redshift_conn_id="redshift",
            aws_credentials_id="aws_credentials",
            table=STAGING_EVENTS_TABLE_NAME,
            s3_bucket=Variable.get('s3_bucket'),
            s3_key=STAGING_EVENTS_S3_KEY,
            jsonpath="s3://{}/{}".format(Variable.get('s3_bucket'),STAGING_EVENTS_JSONPATH_S3_KEY),
            region=Variable.get("region")
        )

        stage_songs_to_redshift = StageToRedshiftOperator(
            task_id="Stage_songs",
            redshift_conn_id="redshift",
            aws_credentials_id="aws_credentials",
            table=STAGING_SONGS_TABLE_NAME,
            s3_bucket=Variable.get('s3_bucket'),
            s3_key=STAGING_SONGS_S3_KEY,
            jsonpath="auto",
            region=Variable.get("region")
        )

    load_songplays_table = LoadFactOperator(
        task_id="Load_songplays_fact_table",
        redshift_conn_id="redshift",
        table_name=FACTS_SONGPLAYS_TABLE_NAME
    )
    
    with TaskGroup("load_dimension_tables") as load_dimensions_table_group:
        


        load_user_dimension_table = LoadDimensionOperator(
            task_id="Load_user_dim_table",
            redshift_conn_id="redshift",
            table_name=DIMENSION_USERS_TABLE_NAME,
            select_statement=sql_transformation_statements.SqlQueries.user_table_insert
        )

        load_song_dimension_table = LoadDimensionOperator(
            task_id="Load_song_dim_table",
            redshift_conn_id="redshift",
            table_name=DIMENSION_SONGS_TABLE_NAME,
            select_statement=sql_transformation_statements.SqlQueries.song_table_insert
        )

        load_artist_dimension_table = LoadDimensionOperator(
            task_id="Load_artist_dim_table",
            redshift_conn_id="redshift",
            table_name=DIMENSION_ARTISTS_TABLE_NAME,
            select_statement=sql_transformation_statements.SqlQueries.artist_table_insert
        )

        load_time_dimension_table = LoadDimensionOperator(
            task_id="Load_time_dim_table",
            redshift_conn_id="redshift",
            table_name=DIMENSION_TIME_TABLE_NAME,
            select_statement=sql_transformation_statements.SqlQueries.time_table_insert
        )

    run_quality_checks = DataQualityOperator(
        task_id="Run_data_quality_checks",
        rules=QUALITY_CHECK_JSON,
        redshift_conn_id="redshift"
    )
    
    end_operator = DummyOperator(task_id='End_execution')
    
    start_operator >> load_stage_table_group >> load_songplays_table >> load_dimensions_table_group
    load_dimensions_table_group >> run_quality_checks >> end_operator
    
final_project_dag = final_project()

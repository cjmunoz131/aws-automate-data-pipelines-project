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

    with TaskGroup("load_stage_events_table") as load_stage_events_table_group:
        recreate_stage_events_table = RecreateTableOperator(
            task_id="RecreateStage_eventsTable",
            redshift_conn_id="redshift",
            table_name=STAGING_EVENTS_TABLE_NAME,
            enableRecreation=bool(Variable.get('recreation-enable')),
            createSQLScript=sql_ddl_statements.DDLSQLQueries.staging_events_table_create
        )
        
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
        
        recreate_stage_events_table >> stage_events_to_redshift

    with TaskGroup("load_stage_songs_table") as load_stage_songs_table_group:

        recreate_stage_songs_table = RecreateTableOperator(
            task_id="RecreateStage_songsTable",
            redshift_conn_id="redshift",
            table_name=STAGING_SONGS_TABLE_NAME,
            enableRecreation=bool(Variable.get('recreation-enable')),
            createSQLScript=sql_ddl_statements.DDLSQLQueries.staging_songs_table_create
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
        
        recreate_stage_songs_table >> stage_songs_to_redshift
    
    with TaskGroup("load_fact_songplays_table") as load_fact_songplays_table_group:
        
        recreateFact_songplaysTable = RecreateTableOperator(
            task_id="RecreateFact_songplaysTable",
            redshift_conn_id="redshift",
            table_name=FACTS_SONGPLAYS_TABLE_NAME,
            enableRecreation=bool(Variable.get('recreation-enable')),
            createSQLScript=sql_ddl_statements.DDLSQLQueries.songplay_table_create
        )

        load_songplays_table = LoadFactOperator(
            task_id="Load_songplays_fact_table",
            redshift_conn_id="redshift",
            table_name=FACTS_SONGPLAYS_TABLE_NAME
        )
    
        recreateFact_songplaysTable >> load_songplays_table
    
    with TaskGroup("load_dimension_users_table") as load_dimension_users_table_group:
    
        recreate_users_table = RecreateTableOperator(
            task_id="RecreateDimension_usersTable",
            redshift_conn_id="redshift",
            table_name=DIMENSION_USERS_TABLE_NAME,
            enableRecreation=bool(Variable.get('recreation-enable')),
            createSQLScript=sql_ddl_statements.DDLSQLQueries.user_table_create
        )

        load_user_dimension_table = LoadDimensionOperator(
            task_id="Load_user_dim_table",
            redshift_conn_id="redshift",
            table_name=DIMENSION_USERS_TABLE_NAME,
            select_statement=sql_transformation_statements.SqlQueries.user_table_insert
        )
        
        recreate_users_table >> load_user_dimension_table
    
    with TaskGroup("load_dimension_songs_table") as load_dimension_songs_table_group:
        
        recreate_songs_table = RecreateTableOperator(
            task_id="RecreateDimension_songsTable",
            redshift_conn_id="redshift",
            table_name=DIMENSION_SONGS_TABLE_NAME,
            enableRecreation=bool(Variable.get('recreation-enable')),
            createSQLScript=sql_ddl_statements.DDLSQLQueries.song_table_create
        )

        load_song_dimension_table = LoadDimensionOperator(
            task_id="Load_song_dim_table",
            redshift_conn_id="redshift",
            table_name=DIMENSION_SONGS_TABLE_NAME,
            select_statement=sql_transformation_statements.SqlQueries.song_table_insert
        )
        
        recreate_songs_table >> load_song_dimension_table
        
    with TaskGroup("load_dimension_artists_table") as load_dimension_artists_table:
    
        recreate_artists_table = RecreateTableOperator(
            task_id="RecreateDimension_astistsTable",
            redshift_conn_id="redshift",
            table_name=DIMENSION_ARTISTS_TABLE_NAME,
            enableRecreation=bool(Variable.get('recreation-enable')),
            createSQLScript=sql_ddl_statements.DDLSQLQueries.artist_table_create
        )

        load_artist_dimension_table = LoadDimensionOperator(
            task_id="Load_artist_dim_table",
            redshift_conn_id="redshift",
            table_name=DIMENSION_ARTISTS_TABLE_NAME,
            select_statement=sql_transformation_statements.SqlQueries.artist_table_insert
        )
        
        recreate_artists_table >> load_artist_dimension_table
        
    with TaskGroup("load_dimension_time_table") as load_dimension_time_table:

        recreate_time_table = RecreateTableOperator(
            task_id="RecreateDimension_timeTable",
            redshift_conn_id="redshift",
            table_name=DIMENSION_TIME_TABLE_NAME,
            enableRecreation=bool(Variable.get('recreation-enable')),
            createSQLScript=sql_ddl_statements.DDLSQLQueries.time_table_create
        )

        load_time_dimension_table = LoadDimensionOperator(
            task_id="Load_time_dim_table",
            redshift_conn_id="redshift",
            table_name=DIMENSION_TIME_TABLE_NAME,
            select_statement=sql_transformation_statements.SqlQueries.time_table_insert
        )
        
        recreate_time_table >> load_time_dimension_table

    run_quality_checks = DataQualityOperator(
        task_id="Run_data_quality_checks",
        rules=QUALITY_CHECK_JSON,
        redshift_conn_id="redshift"
    )
    
    end_operator = DummyOperator(task_id='End_execution')
    
    start_operator >> [load_stage_events_table_group,load_stage_songs_table_group] >> load_fact_songplays_table_group
    load_fact_songplays_table_group >> [load_dimension_users_table_group,load_dimension_songs_table_group,load_dimension_artists_table,load_dimension_time_table] >> run_quality_checks
    run_quality_checks >> end_operator
    
final_project_dag = final_project()

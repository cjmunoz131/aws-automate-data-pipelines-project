from airflow.hooks.postgres_hook import PostgresHook
from airflow.models import BaseOperator
from airflow.utils.decorators import apply_defaults
from helpers.sql_transformation_statements import SqlQueries

class LoadFactOperator(BaseOperator):

    ui_color = '#F98866'

    BULK_INSERT_SQL = """
       INSERT INTO {table} (start_time,
        user_id,
        level,
        song_id,
        artist_id,
        session_id,
        location,
        user_agent
        )
        {select_statement}
    """
    
    @apply_defaults
    def __init__(self,
                 redshift_conn_id="",
                 table_name="",
                 *args, **kwargs):

        super(LoadFactOperator, self).__init__(*args, **kwargs)
        self.redshift_conn_id= redshift_conn_id
        self.table_name = table_name

    def execute(self, context):
        self.log.info('LoadFactOperator starts')
        redshift = PostgresHook(postgres_conn_id=self.redshift_conn_id, autocommit=True)
        insert_sql = LoadFactOperator.BULK_INSERT_SQL.format(table=self.table_name,select_statement=SqlQueries.songplay_table_insert)
        redshift.run(insert_sql)
from airflow.hooks.postgres_hook import PostgresHook
from airflow.models import BaseOperator
from airflow.utils.decorators import apply_defaults

class LoadDimensionOperator(BaseOperator):

    ui_color = '#80BD9E'
    
    truncate_sql = """
        TRUNCATE {table};
    """

    BULK_INSERT_SQL = """
       INSERT INTO {table}
       ({select_statement})
    """
    
    @apply_defaults
    def __init__(self,
                 redshift_conn_id="",
                 table_name="",
                 select_statement="",
                 *args, **kwargs):

        super(LoadDimensionOperator, self).__init__(*args, **kwargs)
        self.redshift_conn_id= redshift_conn_id
        self.table_name = table_name
        self.select_statement = select_statement

    def execute(self, context):
        self.log.info('LoadDimensionOperator starts')
        redshift = PostgresHook(postgres_conn_id=self.redshift_conn_id, autocommit=True)
        redshift.run(LoadDimensionOperator.truncate_sql.format(table=self.table_name))
        redshift.run(LoadDimensionOperator.BULK_INSERT_SQL.format(table=self.table_name,select_statement=self.select_statement))
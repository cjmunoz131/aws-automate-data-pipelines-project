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
                 enableTruncate=True,
                 *args, **kwargs):

        super(LoadDimensionOperator, self).__init__(*args, **kwargs)
        self.redshift_conn_id= redshift_conn_id
        self.table_name = table_name
        self.select_statement = select_statement
        self.enableTruncate = enableTruncate

    def execute(self, context):
        self.log.info('LoadDimensionOperator starts')
        self.log.info('getting Redshift Credentials')
        redshift = PostgresHook(postgres_conn_id=self.redshift_conn_id, autocommit=True)
        if (self.enableTruncate):
            self.log.info('Executing Truncate table: {}'.format(self.table_name))
            redshift.run(LoadDimensionOperator.truncate_sql.format(table=self.table_name))
        else:
            self.log.info('Truncate the dimension table is disabled')
        self.log.info('Executing Bulk insert into {} Dimension Table'.format(self.table_name))
        redshift.run(LoadDimensionOperator.BULK_INSERT_SQL.format(table=self.table_name,select_statement=self.select_statement))
from airflow.hooks.postgres_hook import PostgresHook
from airflow.models import BaseOperator
from airflow.utils.decorators import apply_defaults


class RecreateTableOperator(BaseOperator):
    ui_color = '#358150'
    
    drop_sql_template = """
    DROP TABLE IF EXISTS {table_name}
    """

    @apply_defaults
    def __init__(self,
                 redshift_conn_id="",
                 table_name="",
                 enableRecreation=False,
                 createSQLScript="",
                 *args, **kwargs):

        super(RecreateTableOperator, self).__init__(*args, **kwargs)
        self.redshift_conn_id = redshift_conn_id
        self.table_name = table_name
        self.enableRecreation = enableRecreation
        self.createSQLScript= createSQLScript

    def execute(self, context):
        self.log.info('RecreateTableOperator starts')
        if (self.enableRecreation):
            redshift = PostgresHook(postgres_conn_id=self.redshift_conn_id, autocommit=True)
            redshift.run(RecreateTableOperator.drop_sql_template.format(table_name=self.table_name))
            create_sql = self.createSQLScript.format(table_name=self.table_name)
            redshift.run(create_sql)
        else:
            self.log.info('RecreateTableOperator disabled for table {}'.format(self.table_name))
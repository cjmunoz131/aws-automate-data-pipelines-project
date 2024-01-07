from airflow.hooks.postgres_hook import PostgresHook
from airflow.models import BaseOperator
from airflow.utils.decorators import apply_defaults
from airflow.contrib.hooks.aws_hook import AwsHook

class StageToRedshiftOperator(BaseOperator):
    ui_color = '#358140'
    
    copy_sql = """
        COPY {table}
        FROM 's3://{s3_bucket}/{s3_key}'
        ACCESS_KEY_ID '{access_key}'
        SECRET_ACCESS_KEY '{secret_key}'
        FORMAT AS JSON '{jsonpath}'
        STATUPDATE ON
        EMPTYASNULL
        BLANKSASNULL
        ACCEPTINVCHARS AS '^'
        REGION '{region}'
    """

    @apply_defaults
    def __init__(self,
                 redshift_conn_id="redshift",
                 aws_credentials_id="aws_credentials",
                 table="",
                 s3_bucket="",
                 s3_key="",
                 jsonpath="",
                 region="",
                 *args, **kwargs):

        super(StageToRedshiftOperator, self).__init__(*args, **kwargs)
        self.redshift_conn_id = redshift_conn_id
        self.aws_credentials_id = aws_credentials_id
        self.table = table
        self.s3_bucket = s3_bucket
        self.s3_key = s3_key
        self.jsonpath = jsonpath
        self.region = region

    def execute(self, context):
        self.log.info('StageToRedshiftOperator starts')
        aws_hook = AwsHook(self.aws_credentials_id)
        credentials = aws_hook.get_credentials()
        redshift = PostgresHook(postgres_conn_id=self.redshift_conn_id, autocommit=True)
        s3_key_formatted = self.s3_key.format(year=context['execution_date'].year,month=context['execution_date'].month)
        final_copy_sql = StageToRedshiftOperator.copy_sql.format(table=self.table,s3_bucket=self.s3_bucket,s3_key=s3_key_formatted,access_key=credentials.access_key,secret_key=credentials.secret_key,jsonpath=self.jsonpath,region=self.region)
        redshift.run(final_copy_sql)
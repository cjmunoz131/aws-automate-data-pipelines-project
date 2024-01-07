from airflow.models import BaseOperator
from airflow.utils.decorators import apply_defaults
from base.redshift_quality_checker import RedshiftChecker

class DataQualityOperator(BaseOperator):

    ui_color = '#89DA59'

    @apply_defaults
    def __init__(self,
                 rules,
                 redshift_conn_id="redshift",
                 *args, **kwargs):

        super(DataQualityOperator, self).__init__(*args, **kwargs)
        self.redshiftChecker = RedshiftChecker(rules,self.log,redshift_conn_id)

    def execute(self, context):
        self.log.info('DataQualityOperator starts')
        self.redshiftChecker.check()
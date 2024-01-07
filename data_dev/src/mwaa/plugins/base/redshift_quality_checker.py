from airflow.hooks.postgres_hook import PostgresHook

from base.data_quality_checker import DataQualityChecker

class RedshiftChecker(DataQualityChecker):
    
    ROW_COUNT_SQL_STATEMENT = "SELECT COUNT(*) FROM {table};"
    REGEX_PATTERN_VALID_ROWS_COUNT = "SELECT sum(regexp_count({column}, '{regexp}', 1, 'p')) FROM {table_name};"
    NULLABLE_ROW_COUNT_BY_COLUMN = "SELECT COUNT({column_name}) FROM {table_name} WHERE {column_name} IS NULL;"
    TIMESTAMP_PATTERN_VALID_ROWS_COUNT = "SELECT regexp_count(extract(epoch from {column_name}),'[[:digit:]]{10}', 1, 'p') FROM {table_name};"

    def __init__(self,
                 rules,
                 log,
                 redshift_conn_id):
        super().__init__(rules,log)
        self.redshift_client = self.redshift_client = PostgresHook(postgres_conn_id=redshift_conn_id, autocommit=True)
        
    def __get_valid_rows_with_regex_pattern(self,table_name,column_name,rule_value):
        records = self.redshift_client.get_records(RedshiftChecker.REGEX_PATTERN_VALID_ROWS_COUNT.format(table_name=table_name,column=column_name,regexp=rule_value))
        return records[0][0]
    
    def __get_valid_rows_with_nullable(self,table_name,column_name):
        records = self.redshift_client.get_records(RedshiftChecker.NULLABLE_ROW_COUNT_BY_COLUMN.format(table_name=table_name,column_name=column_name))
        return records[0][0]
    
    def __get_valid_rows_with_timestamp_pattern(self,table_name,column_name):
        records = self.redshift_client.get_records(RedshiftChecker.TIMESTAMP_PATTERN_VALID_ROWS_COUNT.format(table_name=table_name,column_name=column_name))
        return records[0][0]
    
    def get_row_count_by_table(self,table_name):
        records = self.redshift_client.get_records(RedshiftChecker.ROW_COUNT_SQL_STATEMENT.format(table=table_name))
        self.log.info(f"Table rows: {records}")
        return records
        
    def get_valid_rows_count_by_column(self,table_name,column_name,rules):
        valid_rows = 0
        for rule in rules:
            rule_key = list(rule.keys())[0]
            rule_value = list(rule.values())[0]
            if(rule_key=="regexp"):
                valid_rows += self.__get_valid_rows_with_regex_pattern(table_name,column_name,rule_value)
            elif (rule=="nullable"):
                valid_rows += self.__get_valid_rows_with_nullable(table_name,column_name)
            elif (rule=="timestamp"):
                valid_rows += self.__get_valid_rows_with_timestamp_pattern(table_name,column_name)
            return valid_rows
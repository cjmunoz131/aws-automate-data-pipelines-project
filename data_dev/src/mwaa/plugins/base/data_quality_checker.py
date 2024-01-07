from abc import ABC, abstractmethod
import json


class DataQualityChecker(ABC):

    def __init__(self, rules, log):
        self.rules = DataQualityChecker.__load_json(rules)
        self.log = log
        
    @staticmethod
    def __load_json(rules):
        json_file = open(rules)
        data = json.load(json_file)
        json_file.close()
        return data
    
    @abstractmethod
    def get_row_count_by_table(self,table_name):
        pass
    
    @abstractmethod
    def get_valid_rows_count_by_column(self,table_name,column,rules):
        pass
    
    def check(self):
        for table in self.rules:
            records = self.get_row_count_by_table(table["name"])
            if(len(records) < 1 or len(records[0]) < 1 ):
                raise ValueError(f"Data quality check failed. {table['name']} contained 0 rows")
            num_records = records[0][0]
            if num_records < 1:
                raise ValueError(f"Data quality check failed. {table['name']} contained 0 rows")
            for column in table["columns"]:
                validRowsByColumn = self.get_valid_rows_count_by_column(table["name"],column["name"],column["rules"])
                if(validRowsByColumn==num_records):
                    message = f"Data quality on column {column['name']} from table {table['name']} check passed."
                    self.log.info(message)
                else:
                    invalid_rows= abs(num_records-validRowsByColumn)
                    message = f"Data quality check failed. {table['name']} contains invalid records, column_name: {column['name']}, invalid_rows: {invalid_rows}"
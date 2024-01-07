variable "name" {
  type        = string
  description = "name of the mwaa service"
}

variable "airflow_version" {
  type        = string
  description = "version of the apache airflow"
}

variable "environment_class" {
  type        = string
  description = "environment class"
}

variable "min_workers" {
  type        = number
  description = "minimum number of workers for autoscaling"
}

variable "max_workers" {
  type        = number
  description = "maximum number of workers for autoscaling"
}

variable "kms_key" {
  type        = string
  description = "arn of kms encryption key"
}

variable "dag_s3_path" {
  type        = string
  description = "path of the dags in s3 dev tooling bucket"
}

variable "plugins_s3_object_version" {
  type        = string
  description = "plugins s3 object version"
}

variable "plugins_s3_path" {
  type        = string
  description = "path in s3 for plugins"
}

variable "requirements_s3_path" {
  type        = string
  description = "s3 path for requirements.txt"
}

variable "requirements_s3_object_version" {
  type        = string
  description = "object version for requirements"
}

variable "startup_script_s3_path" {
  type        = string
  description = "startup script path in s3"
}

variable "startup_script_s3_object_version" {
  type        = string
  description = "object version for the startup script"
}

variable "schedulers" {
  type        = number
  description = "number of schedulers"
}

variable "execution_role_arn" {
  type        = string
  description = "value"
}

variable "airflow_configuration_options" {
  type = map(string)
}

variable "source_bucket_arn" {
  type        = string
  description = "arn of the source bucket"
}

variable "webserver_access_mode" {
  type        = string
  description = "access mode for the web server of the apache airflow environment"
  default     = "PUBLIC_ONLY"
}

variable "weekly_maintenance_window_start" {
  type        = string
  description = "maintenance window start weekly"
}

variable "security_group_ids" {
  type        = set(string)
  description = "set of security group ids"
}

variable "private_subnet_ids" {
  type        = set(string)
  description = "set of subnets where workers nodes of apache airflow env are deployed"
}

variable "logging_configuration" {
  type = object({
    dag_processing_logs = object({
      enabled   = bool
      log_level = string
    })
    scheduler_logs = object({
      enabled   = bool
      log_level = string
    })
    task_logs = object({
      enabled   = bool
      log_level = string
    })
    webserver_logs = object({
      enabled   = bool
      log_level = string
    })
    worker_logs = object({
      enabled   = bool
      log_level = string
    })
  })
}


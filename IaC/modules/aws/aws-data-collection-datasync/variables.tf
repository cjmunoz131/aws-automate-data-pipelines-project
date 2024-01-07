variable "s3_datalake_arn" {
  type = string
}

variable "datasync_source_location_s3_subdirectory" {
  type = string
}

variable "datasync_target_location_s3_subdirectory" {
  type = string
}

variable "s3_datasource_arn" {
  type = string
}

variable "kms_key_arn" {
  type = string
}

variable "kms_key_source_arn" {
  type = string
}

variable "datasync_task_options" {
  type        = map(string)
  description = "A map of datasync_task options block"
  default = {
    verify_mode            = "POINT_IN_TIME_CONSISTENT"
    posix_permissions      = "NONE"
    preserve_deleted_files = "REMOVE"
    uid                    = "NONE"
    gid                    = "NONE"
    atime                  = "NONE"
    mtime                  = "NONE"
    bytes_per_second       = "-1"
  }
}

variable "datasync_collector_name" {
  type    = string
  default = "STEDI-datasync-collector"
}

variable "datasync_source_location_role" {
  type = string
}

variable "datasync_target_location_role" {
  type = string
}
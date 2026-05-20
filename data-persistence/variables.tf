variable "DEPLOY_NAME" {
  type = string
}

variable "MATURITY" {
  type    = string
  default = "dev"
}

variable "CIRRUS_CORE_VERSION" {
  type    = string
}

variable "CIRRUS_DAAC_VERSION" {
  type    = string
}

variable "db_partition_config" {
  type = object({
    executions_total_years = number
    granules_count         = number
    files_count            = number
  })

  description = <<EOT
    Configuration for database table partitioning:
    - executions_total_years: How many years worth of quarterly partitions to generate for 'executions'.
    - granules_count: The number of hash/bigint-based partitions to create for the 'granules' table.
    - files_count: The number of hash/bigint-based partitions to create for the 'files' table.
  EOT

  default = {
    executions_total_years = 2
    granules_count         = 512
    files_count            = 1024
  }
}
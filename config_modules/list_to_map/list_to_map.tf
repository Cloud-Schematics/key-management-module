##############################################################################
# Variables
##############################################################################

variable "list" {
  description = "List of objects"
  type        = list(any)
}

variable "prefix" {
  description = "Prefix to add to map keys"
  type        = string
  default     = ""
}

variable "key_name_field" {
  description = "Key inside each object to use as the map key"
  type        = string
  default     = "name"
}

variable "lookup_field" {
  description = "Name of the field to find with lookup"
  type        = string
  default     = null
}

variable "lookup_value_regex" {
  description = "regular expression for reurned value"
  type        = string
  default     = null
}

variable "value_is_not_null" {
  description = "Check lookupfield value is not null. Conflicts with `lookup_value_regex`"
  type        = bool
  default     = null
}

##############################################################################

##############################################################################
# Fail States
##############################################################################

locals {
  CONFIGURATION_FAILURE_conflicting_values_lookup_value_regex_and_value_is_not_null = regex("false", (
    var.value_is_not_null == true && var.lookup_value_regex != null
    ? true
    : false
  ))
}

##############################################################################

##############################################################################
# Output
##############################################################################

output "value" {
  description = "List converted into map"
  value = {
    for item in var.list :
    ("${var.prefix == "" ? "" : "${var.prefix}-"}${item[var.key_name_field]}") =>
    item if(
      var.value_is_not_null == true
      ? lookup(item, var.lookup_field, null) != null
      : var.lookup_field == null                                                           # If not looking up
      ? true                                                                               # true
      : can(regex(var.lookup_value_regex, tostring(lookup(item, var.lookup_field, null)))) # Otherwise match regex
    )
  }
}

##############################################################################
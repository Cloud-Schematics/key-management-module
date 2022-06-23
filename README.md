# Key Management Module

This module allows users to create and manage keys, key rings, and key policies in a HPCS or Key Protect Instance.

---

## Table of Contents

1. [Key Management Instance Types](#key-management-instance-types)
2. [Module Variables](#module-variables)
3. [Management Keys and Policies](#management-keys-and-policies)
4. [Service Authorizations](#servive-authorizaions)
5. [Module Outputs](#module-outputs)

---

## Key Management Instance Types

This module supports these three patterns for a key management instance:
- Use an intialized Hyper Protect Crypto Services. (For more information about HPCS see the documentation [here](https://cloud.ibm.com/docs/hs-crypto?topic=hs-crypto-get-started).)
- Use an existing Key Protect Instance
- Create a New Key Protect instance

---

## Module Variables

Name                      | Type         | Description                                                                                                                                                                                                                                                   | Default
------------------------- | ------------ | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | -------
region                    | string       | The region to which to deploy the VPC                                                                                                                                                                                                                         | 
prefix                    | string       | The prefix that you would like to append to your resources                                                                                                                                                                                                    | 
tags                      | list(string) | List of Tags for the resource created                                                                                                                                                                                                                         | null
resource_group_id         | string       | Resource group ID to use for provision of resources or to find existing resources.                                                                                                                                                                            | null
service_endpoints         | string       | Service endpoints. Can be `public`, `private`, or `public-and-private`                                                                                                                                                                                        | private
use_hs_crypto             | bool         | Use HyperProtect Crypto Services. HPCS cannot be initialized in this module.                                                                                                                                                                                  | false
use_data                  | bool         | Use existing Key Protect instance.                                                                                                                                                                                                                            | false
authorize_vpc_reader_role | bool         | Create a service authorization to allow the key management service created by this module Reader role for IAM access to VPC block storage resources. This allows for block storage volumes for VPC to be encrypted using keys from the key management service | true
name                      | string       | Name of the service to create or find from data. Created service instances will include the prefix.                                                                                                                                                           | kms

---

## Management Keys and Policies

Management keys and policies are created using the [keys variable](./variables#L68).

```terraform
variable "keys" {
  description = "List of keys to be created for the service"
  type = list(
    object({
      name            = string           # Name of the key
      root_key        = optional(bool)   # is a root key
      payload         = optional(string)
      key_ring        = optional(string) # Any key_ring added will be created
      force_delete    = optional(bool)   # Force delete key. Will be true unless this value is set to `false`
      endpoint        = optional(string) # can be public or private
      iv_value        = optional(string) # (Optional, Forces new resource, String) Used with import tokens. The initialization vector (IV) that is generated when you encrypt a nonce. The IV value is required to decrypt the encrypted nonce value that you provide when you make a key import request to the service. To generate an IV, encrypt the nonce by running ibmcloud kp import-token encrypt-nonce. Only for imported root key.
      encrypted_nonce = optional(string) # The encrypted nonce value that verifies your request to import a key to Key Protect. This value must be encrypted by using the key that you want to import to the service. To retrieve a nonce, use the ibmcloud kp import-token get command. Then, encrypt the value by running ibmcloud kp import-token encrypt-nonce. Only for imported root key.
      policies = optional(
        object({
          rotation = optional(
            object({
              interval_month = number
            })
          )
          dual_auth_delete = optional(
            object({
              enabled = bool
            })
          )
        })
      )
    })
  )
  ...
}
```

---

## Servive Authorizaions

By setting the `authorize_vpc_reader_role` variable to true, an IAM policy is created to allow the Key Management instance and keys used by this module to encrypt VPC Block Storage Volumes

---

## Module Outputs

Name                | Description
------------------- | ---------------------------------------
key_management_name | Name of key management service
key_management_crn  | CRN for KMS instance
key_management_guid | GUID for KMS instance
key_rings           | Key rings created by module
keys                | List of names and ids for keys created.


The keys output has the following fields:
```terraform
output "keys" {
  description = "List of names and ids for keys created."
  value = [
    for kms_key in var.keys :
    {
      shortname = kms_key.name # Name of key without prefix
      name      = ibm_kms_key.key[kms_key.name].key_name
      id        = ibm_kms_key.key[kms_key.name].id
      crn       = ibm_kms_key.key[kms_key.name].crn
      key_id    = ibm_kms_key.key[kms_key.name].key_id
    }
  ]
}
```
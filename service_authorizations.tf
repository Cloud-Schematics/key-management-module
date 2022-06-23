##############################################################################
# Create Service to Service Authorization from VPC to Key Protect to allow 
# for VPC Block Stroage volumes to use key management keys
##############################################################################

resource "ibm_iam_authorization_policy" "policy" {
  count                       = var.authorize_vpc_reader_role == true ? 1 : 0
  source_service_name         = "server-protect"
  target_service_name         = local.use_hs_crypto == true ? "hs-crypto" : "kms"
  target_resource_instance_id = local.key_management_guid
  roles                       = ["Reader"]
  description                 = "Allow block storage volumes to be encrypted by Key Management instance."
}

##############################################################################
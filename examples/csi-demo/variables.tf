variable "do_token" {}

variable "do-ssh-key" {
  default     = "5f:99:f9:3d:59:3f:7d:04:44:90:a7:9f:98:2c:79:2c"               # mew ssh key
  description = "MD5 of an SSH Key that is already registered with digialocean"
}

variable "nomad_target_branch" {
  default = "hack-csi-demo"
}

variable "resource_prefix" {
  default = "nomad-storage-demo"
}

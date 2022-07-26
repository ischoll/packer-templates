# variables.tf
# Declare all the variables needed
variable "vsphereuser" {
    type = string
    sensitive = true
}
variable "vspherepass" {
    type = string
    sensitive = true
}
variable "vsphere-vcenter" {
    type = string
}
variable "vsphere-unverified-ssl" {
    type = string
}
variable "vsphere-datacenter" {
    type = string
}
variable "vsphere-cluster" {
    type = string
    default = ""
}
variable "vsphere_user" {
}
variable "vsphere_password" {
}
variable "vsphere_server" {
  default = ""
}
variable "bot-count" {
    type = string
    description = "Number of Bot VM's"
    default     =  0
}
variable "worker-count" {
    type = string
    description = "Number of Worker VM's"
    default     =  0
}
variable "vm-datastore" {
    type = string
}
variable "vm-network" {
    type = string
}
variable "vm-cpu" {
    type = string
    default = "2"
}
variable "vm-ram" {
    type = string
}
variable "vm-prefix" {
    type = string
}
variable "vm-guest-id" {
    type = string
}
variable "vm-template-name" {
    type = string
}
variable "vm-domain" {
    type = string
}
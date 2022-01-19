# variables.tf
# Declare all the variables needed
variable "vsphereuser" {
    type = string
}
variable "vspherepass" {
    type = string
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
variable "control-count" {
    type = string
    description = "Number of Control VM's"
    default     =  2
}
variable "worker-count" {
    type = string
    description = "Number of Worker VM's"
    default     =  2
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
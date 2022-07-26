# main.tf

locals {
  hostnames = csvdecode(file("hostnames.csv"))
}
# Configure the vSphere provider
provider "vsphere" {
    # user = var.vsphereuser
    # password = var.vspherepass
    # vsphere_server = var.vsphere-vcenter
    # allow_unverified_ssl = var.vsphere-unverified-ssl

    user           = "${var.vsphere_user}"
    password       = "${var.vsphere_password}"
    vsphere_server = "${var.vsphere_server}"
    allow_unverified_ssl = true

}

data "vsphere_datacenter" "dc" {
    name = var.vsphere-datacenter
}

data "vsphere_datastore" "datastore" {
    name = var.vm-datastore
    datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_compute_cluster" "cluster" {
    name = var.vsphere-cluster
    datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_network" "network" {
    name = var.vm-network
    datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_virtual_machine" "template" {
    name = var.vm-template-name
    datacenter_id = data.vsphere_datacenter.dc.id
}

# Create VM Folder
resource "vsphere_folder" "folder" {
  path          = "2004_bots"
  type          = "vm"
  datacenter_id = data.vsphere_datacenter.dc.id
}

# Create Control VMs
resource "vsphere_virtual_machine" "control" {
    for_each =  { for inst in local.hostnames :  inst.hostname => inst}
    #for_each =  { for inst in local.hostnames :  inst.ip => inst}
    name = "${var.vm-prefix}-${each.value.hostname}"
    resource_pool_id = data.vsphere_compute_cluster.cluster.resource_pool_id
    datastore_id = data.vsphere_datastore.datastore.id
    folder = vsphere_folder.folder.path
    num_cpus = var.vm-cpu
    memory = var.vm-ram
    guest_id = var.vm-guest-id



    network_interface {
        network_id = data.vsphere_network.network.id
    }

    disk {
        label = "${var.vm-prefix}-disk"
        size  = 32
    }

    clone {
        template_uuid = data.vsphere_virtual_machine.template.id
        customize {
            timeout = 0

            linux_options {
            host_name = "${var.vm-prefix}-${each.value.hostname}"
            domain = var.vm-domain
            }

            network_interface {
            ipv4_address = each.value.ip
            ipv4_netmask = 24
            }

            ipv4_gateway = "10.0.5.1"
            dns_server_list = [ "10.0.0.101" ]

        }
    }
}

# output "control_ip_addresses" {
#  value = vsphere_virtual_machine.control.*.default_ip_address
# }


# output "control_hostnames" {
#  value = vsphere_virtual_machine.control.*.name
# }


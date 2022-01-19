# main.tf

# Configure the vSphere provider
provider "vsphere" {
    user = var.vsphereuser
    password = var.vspherepass
    vsphere_server = var.vsphere-vcenter
    allow_unverified_ssl = var.vsphere-unverified-ssl
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
  path          = "k8s-HA"
  type          = "vm"
  datacenter_id = data.vsphere_datacenter.dc.id
}

# Create Control VMs
resource "vsphere_virtual_machine" "control" {
    count = var.control-count
    name = "${var.vm-prefix}-controller-${count.index + 1}"
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
        label = "${var.vm-prefix}-${count.index + 1}-disk"
        size  = 32
    }

    clone {
        template_uuid = data.vsphere_virtual_machine.template.id
        customize {
            timeout = 0

            linux_options {
            host_name = "${var.vm-prefix}-controller-${count.index + 1}"
            domain = var.vm-domain
            }

            network_interface {
            ipv4_address = "10.0.0.19${count.index + 1}"
            ipv4_netmask = 24
            }

            ipv4_gateway = "10.0.0.1"
            dns_server_list = [ "10.0.0.101" ]

        }
    }
}

# Create Worker VMs
resource "vsphere_virtual_machine" "worker" {
    count = var.worker-count
    name = "${var.vm-prefix}-worker-${count.index + 1}"
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
        label = "${var.vm-prefix}-${count.index + 1}-disk"
        size  = 32
    }

    clone {
        template_uuid = data.vsphere_virtual_machine.template.id
        customize {
            timeout = 0

            linux_options {
            host_name = "${var.vm-prefix}-worker-${count.index + 1}"
            domain = var.vm-domain
            }

            network_interface {
            ipv4_address = "10.0.0.18${count.index + 1}"
            ipv4_netmask = 24
            }

            ipv4_gateway = "10.0.0.1"
            dns_server_list = [ "10.0.0.101" ]
        }
    }
}

output "control_ip_addresses" {
 value = vsphere_virtual_machine.control.*.default_ip_address
}

output "worker_ip_addresses" {
 value = vsphere_virtual_machine.worker.*.default_ip_address
}
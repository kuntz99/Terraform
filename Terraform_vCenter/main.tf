provider "vsphere" {
  vsphere_server = "${var.vsphere_server}"
  user = "${var.name}"
  password = "${var.password}"
  # If you have a self-signed cert
  allow_unverified_ssl = true
}


data "vsphere_datacenter" "dc" {
  name = "SCBLIFE_DATACENTER_CW"
}

#variable "var.username" {
#    description = "Enter the username for vCenter"
#}

#variable "vsphere_password" {
#    description = "Enter the username for vCenter"
#}

data "vsphere_datastore" "datastore" {
  name          = "SNT_SSD_DEV_DST_D034"
  datacenter_id = "${data.vsphere_datacenter.dc.id}"
}

data "vsphere_resource_pool" "pool" {
  name          = "PT"
  datacenter_id = "${data.vsphere_datacenter.dc.id}"
}

data "vsphere_network" "network" { 
  name          = "VL0625_UAT1"
  datacenter_id = "${data.vsphere_datacenter.dc.id}"
}

data "vsphere_virtual_machine" "template" {
  name          = "Ubutu_16.04_20180330"
  datacenter_id = "${data.vsphere_datacenter.dc.id}"
}

resource "vsphere_virtual_machine" "vm" {
  name             = "terraform-test"
  resource_pool_id = "${data.vsphere_resource_pool.pool.id}"
  datastore_id     = "${data.vsphere_datastore.datastore.id}"
  efi_secure_boot_enabled = true

  num_cpus = 2
  memory   = 1024
  guest_id = "${data.vsphere_virtual_machine.template.guest_id}"

  scsi_type = "${data.vsphere_virtual_machine.template.scsi_type}"

  network_interface {
    network_id   = "${data.vsphere_network.network.id}"
    adapter_type = "${data.vsphere_virtual_machine.template.network_interface_types[0]}"
  }

  disk {
    label            = "disk0"
    size             = "${data.vsphere_virtual_machine.template.disks.0.size}"
    eagerly_scrub    = "${data.vsphere_virtual_machine.template.disks.0.eagerly_scrub}"
    thin_provisioned = "${data.vsphere_virtual_machine.template.disks.0.thin_provisioned}"
  }

  clone {
    template_uuid = "${data.vsphere_virtual_machine.template.id}"
    
    customize {
      linux_options {
        host_name = "terraform-test"
        domain    = "scnyl.local"
        
      }

      network_interface {
        ipv4_address = "10.21.212.42"
        ipv4_netmask = 26
       
      }

      ipv4_gateway = "10.21.212.62"
      dns_server_list = ["10.21.212.6"]
      
      
    }
  }
}


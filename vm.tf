################################################################
# Module to deploy an VM with specified applications installed
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Licensed Materials - Property of IBM
#
# ©Copyright IBM Corp. 2017
#
################################################################
variable "hostname" {
  default = "lamp"
  description = "LAMP stack using IaC"
}
variable "domain" {
  default = "IBM.cloud"
  description = "The domain for the instance."
}
variable "datacenter" {
  default = "wdc01"
  description = "The data center to create resources in."
}
variable "os_reference_code" {
  default = "CENTOS_7"
  description = "The operating system reference code used to provision the computing instance."
}
variable "cores" {
  default = "1"
  description = "The number of CPU cores to allocate."
}
variable "memory" {
  default = "1024"
  description = "The amount of memory (in Mb) to allocate."
}
variable "disk_size" {
  default = "25"
  description = "The numeric disk sizes (in GB) for the instance’s block device and disk image settings."
}
variable "private_network_only" {
  default = "false"
  description = "When set to true, a compute instance only has access to the private network."
}
variable "network_speed" {
  default = "100"
  description = "The connection speed (in Mbps) for the instance’s network components."
}
variable "tags" {
  default = "LAMP"
  description = "Descriptive tags to label the resource."
}

variable "ssh_user" {
  default = "root"
  description = "The default username for the VM."
}
variable "ssh_label" {
  default = "public ssh key - Schematics VM"
  description = "An identifying label to assign to the SSH key."
}
variable "ssh_notes" {
  default = "SSH_note"
  description = "A description to assign to the SSH key."
}
variable "ssh_key" {
  default = "<ADD-ssh_key-Here>"
  description = "Your public SSH key to access the VM."
}

resource "ibm_compute_ssh_key" "ssh_key" {
    label = "${var.ssh_label}"
    notes = "${var.ssh_notes}"
    public_key = "${var.ssh_key}"
}

resource "ibm_compute_vm_instance" "vm" {
  hostname                 = "${var.hostname}"
  os_reference_code        = "${var.os_reference_code}"
  domain                   = "${var.domain}"
  datacenter               = "${var.datacenter}"
  network_speed            = "${var.network_speed}"
  hourly_billing           = true
  private_network_only     = "${var.private_network_only}"
  cores                    = "${var.cores}"
  memory                   = "${var.memory}"
  disks                    = ["${var.disk_size}"]
  dedicated_acct_host_only = true
  local_disk               = false
  ssh_key_ids              = ["${ibm_compute_ssh_key.ssh_key.id}"]
  tags                     = ["${var.tags}"]
  user_metadata            = "${file("install.yml")}"
}

output "public_ip" {
	value = "http://${ibm_compute_vm_instance.vm.ipv4_address}"
}

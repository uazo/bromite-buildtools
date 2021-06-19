terraform {
  backend "remote" {
    organization = "uazo-bromite"

    workspaces {
      name = "bromite-ci"
    }
  }
}

provider "oci" {
  tenancy_ocid     = "${var.tenancy_ocid}"
  user_ocid        = "${var.user_ocid}"
  fingerprint      = "${var.fingerprint}"
  private_key_path = "${var.private_oci_key_path}"
  region           = "${var.region}"
}

resource "oci_core_vcn" "ci_vcn" {
  compartment_id = "${var.compartment_id}"
  cidr_blocks = ["10.0.1.0/24"]
}

resource "oci_core_internet_gateway" "ci_internet_gateway" {
  vcn_id         = oci_core_vcn.ci_vcn.id
  compartment_id = "${var.compartment_id}"
  enabled        = true
}

resource "oci_core_default_route_table" "ci_route_table" {
  compartment_id = "${var.compartment_id}"
  manage_default_resource_id = oci_core_vcn.ci_vcn.default_route_table_id
  route_rules {
    network_entity_id = oci_core_internet_gateway.ci_internet_gateway.id
    destination = "0.0.0.0/0"
    destination_type = "CIDR_BLOCK"
  }
}

resource "oci_core_default_security_list" "ci_security_list" {
  compartment_id = "${var.compartment_id}"
  manage_default_resource_id = oci_core_vcn.ci_vcn.default_security_list_id
  egress_security_rules {
    stateless        = false
    destination      = "0.0.0.0/0"
    destination_type = "CIDR_BLOCK"
    protocol         = "all" 
  }

  ingress_security_rules {
    protocol = "6" # TCP
    source = "0.0.0.0/0"
    tcp_options {
      min = 50051
      max = 50051
    }
  }

  ingress_security_rules {
    protocol = "6" # TCP
    source = "0.0.0.0/0"
    tcp_options {
      min = 22
      max = 22
    }
  }
}

resource "oci_core_subnet" "ci_subnet" {
  vcn_id         = oci_core_vcn.ci_vcn.id
  cidr_block     = "10.0.1.0/24"
  compartment_id = "${var.compartment_id}"
}

resource "oci_core_instance" "buildgrid0" {
  display_name        = "buildgrid0"
  availability_domain = "${var.availability_domain}"
  compartment_id      = "${var.compartment_id}"
  shape               = "VM.Standard.E2.1.Micro"

  create_vnic_details {
    assign_public_ip = true
    subnet_id        = oci_core_subnet.ci_subnet.id
  }
	
  source_details {
    source_type = "image"
    source_id   = "ocid1.image.oc1.eu-frankfurt-1.aaaaaaaa3mdsbx7kel54yf55ugtfwsvegivhvtidxlfrofwzqlfsg4nb4dxa"
  }

  metadata = {
    ssh_authorized_keys = file("${var.ssh_authorized_keys}")
  }

  timeouts {
    create = "15m"
  }

  connection {
    type        = "ssh"
    host        = "${self.public_ip}"
    user        = "${var.userid}"
    private_key = file("${var.public_key}")
    timeout     = "5m"
  }
  
  provisioner "file" {
    source      = "buildgrid.yml"
    destination = "buildgrid.yml"
  }

  provisioner "remote-exec" {
    inline = [
      "set -o errexit",
      
      "echo waiting 90s",
      "sleep 90s",

      "echo apt updating",
      "sudo apt-get update",
      "sudo apt-get -y upgrade",
      
      "echo installing pre-reqs",
      "sudo apt-get install -y python3 python3-venv git firewalld",
      
      "echo cloning buildgrid repo",
      "git clone https://gitlab.com/BuildGrid/buildgrid.git",
      "cd buildgrid/",

      "echo setting up",
      "python3 -m venv env",
      "env/bin/python -m pip install --upgrade setuptools pip wheel",
      "env/bin/python -m pip install --editable .",

      "echo opening tcp port",
      "sudo firewall-cmd --zone=public --permanent --add-port=50051/tcp",
      "sudo firewall-cmd --reload",

      "nohup env/bin/bgd server start ../buildgrid.yml &",
      "sleep 30s",
    ]
  }
}

data "oci_core_instance" "instance" {
  instance_id = oci_core_instance.buildgrid0.id
}

output "instance_ip" {
  value = data.oci_core_instance.instance.public_ip
}
#terraform output instance_ip

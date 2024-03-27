resource "google_compute_network" "vpc_network" {
  project                 = "banded-elevator-418317"
  name                    = "network-gmxamerica"
  auto_create_subnetworks = false
  mtu                     = 1460
}

resource "google_compute_subnetwork" "default" {
  project       = "banded-elevator-418317"
  name          = "gmxamerica-subnet"
  ip_cidr_range = "10.0.1.0/24"
  region        = "us-west1"
  network       = google_compute_network.vpc_network.id
}

#Create a single Compute Engine instance
resource "google_compute_instance" "default" {
  project      = "banded-elevator-418317"
  name         = "lupin3"
  machine_type = "f1-micro"
  zone         = "us-west1-a"
  tags         = ["webserver"]

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-12"
    }
  }

  # Install Apache
  metadata_startup_script = "sudo apt-get update; sudo apt-get install -y apache2 php google-osconfig-agent"

  network_interface {
    subnetwork = google_compute_subnetwork.default.id

    access_config {
      # Include this section to give the VM an external IP address
    }
  }
}
resource "google_compute_firewall" "ssh" {
  project = "banded-elevator-418317"
  name = "allow-ssh"
  allow {
    ports    = ["22"]
    protocol = "tcp"
  }
  direction     = "INGRESS"
  network       = google_compute_network.vpc_network.id
  priority      = 1000
  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["ssh"]
}

resource "google_compute_firewall" "apache" {
  project = "banded-elevator-418317"
  name    = "apache-app-firewall"
  network = google_compute_network.vpc_network.id

  allow {
    protocol = "tcp"
    ports    = ["80"]
  }
  source_ranges = ["0.0.0.0/0"]
}

// A variable for extracting the external IP address of the VM
output "Web-server-URL" {
 value = join("",["http://",google_compute_instance.default.network_interface.0.access_config.0.nat_ip,":80"])
}
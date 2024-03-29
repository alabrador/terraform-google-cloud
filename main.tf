resource "google_compute_network" "vpc_network" {
  project                 = "banded-elevator-418317"
  name                    = "network-prueba"
  auto_create_subnetworks = false
  mtu                     = 1460
}

resource "google_compute_subnetwork" "default" {
  project       = "banded-elevator-418317"
  name          = "prueba-subnet"
  ip_cidr_range = "10.0.1.0/24"
  region        = "us-west1"
  network       = google_compute_network.vpc_network.id
}

#Create a single Compute Engine instance
resource "google_compute_instance" "default" {
  project      = "banded-elevator-418317"
  name         = "prueba-terraform"
  machine_type = "f1-micro"
  zone         = "us-west1-a"
  tags         = ["terraform", "jenkins"]

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-12"
    }
  }

  # Install Apache
  metadata_startup_script = "sudo apt-get update; sudo apt-get install -y certbot nginx google-osconfig-agent"

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

resource "google_compute_firewall" "nginx" {
  project = "banded-elevator-418317"
  name    = "nginx-app-firewall"
  network = google_compute_network.vpc_network.id

  allow {
    protocol = "tcp"
    ports    = ["80"]
  }
  source_ranges = ["0.0.0.0/0"]
}
#Create a single Compute Engine instance
resource "google_compute_instance" "default" {
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
  metadata_startup_script = "sudo apt-get update; sudo apt-get install -yq apache2 php; systemctl start apache2"

  network_interface {
    subnetwork = google_compute_subnetwork
  }
}

// A variable for extracting the external IP address of the VM
output "Web-server-URL" {
 value = join("",["http://",google_compute_instance.network_interface.0.access_config.0.nat_ip,":80"])
}
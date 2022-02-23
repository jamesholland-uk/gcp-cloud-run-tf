# google cloud run service for processing uploads
resource "google_cloud_run_service" "nautobot" {
  location = var.gcp_region
  name     = "${random_pet.unique.id}-nautobot"

  template {
    spec {
      timeout_seconds = 300
      containers {
        image = "gcr.io/jh-nautobot/networktocode/nautobot-lab:latest"
        ports {
          container_port = 8000
        }
        resources {
          limits = {
            cpu    = "1000m"
            memory = "1024Mi"
          }
        }
      }
    }
  }

  traffic {
          percent         = 100
          latest_revision = true
    }
}

data "google_iam_policy" "noauth" {
      binding {
        role = "roles/run.invoker"
        members = [
          "allUsers",
          ]
      }
}

resource "google_cloud_run_service_iam_policy" "noauth" {
  location    = var.gcp_region
  service     = google_cloud_run_service.nautobot.name
  policy_data = data.google_iam_policy.noauth.policy_data
}

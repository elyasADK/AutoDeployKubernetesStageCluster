resource "kubernetes_cron_job_v1" "keep-updated-stage" {
  metadata {
    name      = "keep-updated-stage"
    namespace = local.namespace
  }

  spec {
    concurrency_policy            = "Forbid"
    failed_jobs_history_limit     = 1
    schedule                      = "*/30 * * * *"
    starting_deadline_seconds     = 10
    successful_jobs_history_limit = 0

    job_template {
      metadata {
        labels = {
          app = "stage"
        }
      }

      spec {
        backoff_limit              = 2
        ttl_seconds_after_finished = 10

        template {
          metadata {}
          spec {
            
            image_pull_secrets {
              name = "docker-registry"
            }

            service_account_name = "keep-update-stage"

            container {
              name              = "keep-updated-stage"
              image             = "[YOUR ORGANIZATION]/keep-update-stage:[VERSION]"
              image_pull_policy = "Always"
       
              env {
                name  = "docker_username"
                value = var.docker_username
              }
              env {
                name  = "docker_password"
                value = var.docker_password
              }
       
              security_context {
                allow_privilege_escalation = false
                run_as_non_root            = true
                run_as_group               = 0
                run_as_user                = 1000
                seccomp_profile {
                  type = "RuntimeDefault"
                }
                capabilities {
                  drop = ["ALL"]
                }
              }
            }
          }
        }
      }
    }
  }
}

# Automatic Pod Image Updater

This is a bash script, which compares the SHA of running pods (in this case on the Kubernetes stage cluster) with the SHA of the latest images with a given tag available on Dockerhub.

If the SHAs differ (i.e. `release-next` tag has been updated with a new image) it will delete the pod, causing our deployments/statefulsets to recreate it and pull the updated image.

Run this image as a cronjob in cluster

DONT FORGET TO ADD SECRET TO YOUR CLUSTER.

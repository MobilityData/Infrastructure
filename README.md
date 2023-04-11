# GTFS Infrastructure

## One-Time Setup

These steps must be performed once at creation time of the project

### terraform

1. Create a bucket for terraform state

  ```bash
  gcloud storage buckets create gs://gtfs-infrastructure-tfstate
  ```

### github actions

1. Create a service account

  ```bash
  gcloud iam service-accounts create github-actions \
    --display-name="GitHub Actions Runner"
  ```

2. Grant the account privileges to manage the project

  ```bash
  gcloud projects add-iam-policy-binding web-based-gtfs-validator \
    --member=serviceAccount:github-actions@web-based-gtfs-validator.iam.gserviceaccount.com \
    --role=roles/owner
  ```

3. Provision a key for the service account

  ```bash
  gcloud iam service-accounts keys create .git/github-actions-sa.json \
    --iam-account=github-actions@web-based-gtfs-validator.iam.gserviceaccount.com
  ```

4. Upload the key to a GitHub Actions secret

  ```bash
  gh -R MobilityData/gtfs-infrastructure secret set GCP_SA_KEY < .git/github-actions-sa.json
  ```

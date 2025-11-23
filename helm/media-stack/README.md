# Media Stack Helm Chart

A complete media automation and streaming stack for Minikube, including:

- **SABnzbd**: Usenet downloader
- **Sonarr**: TV show management and automation
- **Radarr**: Movie management and automation
- **Bazarr**: Subtitle management
- **Jellyfin**: Media server for streaming

## Prerequisites

- Kubernetes 1.19+
- Helm 3.0+
- Minikube with sufficient resources
- At least 80Gi of available storage

## Installation

### Quick Start

```bash
# Install the complete media stack
helm install media-stack ./helm/media-stack

# Install with custom values
helm install media-stack ./helm/media-stack -f my-values.yaml
```

### Accessing the Applications

After installation, the applications will be available at:

| Application | URL                          | NodePort |
| ----------- | ---------------------------- | -------- |
| SABnzbd     | http://\<minikube-ip\>:30081 | 30081    |
| Sonarr      | http://\<minikube-ip\>:30082 | 30082    |
| Radarr      | http://\<minikube-ip\>:30083 | 30083    |
| Bazarr      | http://\<minikube-ip\>:30084 | 30084    |
| Jellyfin    | http://\<minikube-ip\>:30085 | 30085    |

Get your Minikube IP:

```bash
minikube ip
```

Or use Minikube service commands:

```bash
minikube service media-stack-sabnzbd
minikube service media-stack-sonarr
minikube service media-stack-radarr
minikube service media-stack-bazarr
minikube service media-stack-jellyfin
```

## Configuration

### Storage

The chart supports two storage modes:

#### Local Storage (Default)

The chart creates shared persistent volumes for:

- **Media**: 50Gi (shared by all applications)
- **Downloads**: 20Gi (shared download folder)
- **Config**: Individual volumes for each application (1-2Gi each)

Adjust storage sizes in `values.yaml`:

```yaml
persistence:
  media:
    size: 100Gi
  downloads:
    size: 50Gi
```

#### S3 Storage (Optional)

For production deployments with larger media libraries, you can use AWS S3 or S3-compatible storage:

```yaml
s3:
  enabled: true
  bucketName: "my-media-bucket"
  region: "us-east-1"
  # Optional: for MinIO or other S3-compatible storage
  # endpoint: "http://minio.example.com:9000"
  # usePathStyle: true
```

**Prerequisites for S3 Storage:**
- S3 bucket created in AWS
- EC2 instance with IAM role that has S3 access permissions
- Applications configured to use S3 paths

**Note:** The S3 configuration provides environment variables to the applications. Individual application configuration is still required to point media paths to S3 bucket locations. See the [S3 Integration Guide](#s3-integration-guide) below.

### Resources

Default resource limits per application:

- SABnzbd: 1 CPU, 1Gi RAM
- Sonarr/Radarr/Bazarr: 500m CPU, 512Mi RAM
- Jellyfin: 2 CPU, 2Gi RAM

Adjust in `values.yaml`:

```yaml
sonarr:
  resources:
    limits:
      cpu: 1000m
      memory: 1Gi
```

### Timezone

Set timezone globally:

```yaml
global:
  timezone: "America/Los_Angeles"
```

### Disable Components

Disable individual applications:

```yaml
bazarr:
  enabled: false
```

## Initial Setup

### 1. SABnzbd Setup

1. Access SABnzbd at port 30081
2. Complete the initial setup wizard
3. Configure your Usenet provider
4. Set download folder to `/downloads`

### 2. Sonarr Setup

1. Access Sonarr at port 30082
2. Settings → Media Management → Root Folders → Add: `/tv`
3. Settings → Download Clients → Add SABnzbd
   - Host: `media-stack-sabnzbd` (service name)
   - Port: `8080`

### 3. Radarr Setup

1. Access Radarr at port 30083
2. Settings → Media Management → Root Folders → Add: `/movies`
3. Settings → Download Clients → Add SABnzbd
   - Host: `media-stack-sabnzbd`
   - Port: `8080`

### 4. Bazarr Setup

1. Access Bazarr at port 30084
2. Settings → Sonarr → Add server
   - Address: `http://media-stack-sonarr:8989`
3. Settings → Radarr → Add server
   - Address: `http://media-stack-radarr:7878`

### 5. Jellyfin Setup

1. Access Jellyfin at port 30085
2. Complete initial setup wizard
3. Add media libraries:
   - TV Shows: `/media` (or `/tv`)
   - Movies: `/media` (or `/movies`)

## Volume Structure

```
/config           # Application configuration (per-app)
/downloads        # Shared downloads folder (SABnzbd output)
/media or /tv     # TV shows (Sonarr, Jellyfin)
/media or /movies # Movies (Radarr, Jellyfin)
```

## Upgrading

```bash
# Upgrade with new values
helm upgrade media-stack ./helm/media-stack -f values.yaml

# Rollback if needed
helm rollback media-stack
```

## Uninstallation

```bash
# Uninstall the chart
helm uninstall media-stack

# Persistent volumes are not automatically deleted
# Delete them manually if needed:
kubectl delete pvc -l app.kubernetes.io/name=media-stack
```

## Troubleshooting

### Check Pod Status

```bash
kubectl get pods -l app.kubernetes.io/name=media-stack
```

### View Logs

```bash
kubectl logs -l app.kubernetes.io/component=sonarr
kubectl logs -l app.kubernetes.io/component=radarr
kubectl logs -l app.kubernetes.io/component=jellyfin
```

### Storage Issues

```bash
# Check PVCs
kubectl get pvc

# Check available storage in Minikube
minikube ssh
df -h
```

### Permission Issues

The containers run as PUID/PGID 1000 by default. If you encounter permission errors, ensure your storage supports this.

## Advanced Configuration

### Using External Storage

To use NFS or other external storage:

```yaml
global:
  storageClass: "nfs-client"
```

### Custom Image Tags

Use specific versions:

```yaml
sonarr:
  image:
    tag: "4.0.0"
```

### Port Forwarding

For local development, forward ports:

```bash
kubectl port-forward svc/media-stack-jellyfin 8096:8096
```

## Network Architecture

All applications communicate via Kubernetes service names:

- `media-stack-sabnzbd:8080`
- `media-stack-sonarr:8989`
- `media-stack-radarr:7878`
- `media-stack-bazarr:6767`
- `media-stack-jellyfin:8096`

## Security Notes

⚠️ **Important**: This configuration uses NodePort services for easy access on Minikube. For production:

- Use Ingress with TLS
- Implement authentication
- Use NetworkPolicies
- Consider VPN access

## S3 Integration Guide

### Setting up S3 Storage

#### 1. Terraform Configuration

The Terraform stack includes an S3 bucket module specifically designed for media storage. To enable it:

1. The S3 bucket is automatically created when you apply the Terraform configuration
2. An IAM role with S3 access permissions is attached to the EC2 instance
3. The bucket is configured with Intelligent-Tiering for cost optimization

**Bucket Features:**
- **Encryption**: Server-side encryption (AES256) enabled by default
- **Lifecycle**: Intelligent-Tiering automatically moves objects between access tiers
- **Security**: Public access blocked, SSL/TLS enforced
- **Permissions**: EC2 instance can read, write, and delete objects

#### 2. Enable S3 in Helm Chart

Update your `values.yaml`:

```yaml
s3:
  enabled: true
  bucketName: "dev-my-project-media"  # Use the bucket name from Terraform output
  region: "us-east-1"
```

Deploy or upgrade the Helm chart:

```bash
helm upgrade --install media-stack ./helm/media-stack -f values.yaml
```

#### 3. Configure Applications

The S3 configuration provides the following environment variables to all media stack applications:
- `AWS_REGION`: AWS region of the S3 bucket
- `S3_BUCKET`: Name of the S3 bucket
- `S3_ENDPOINT`: (Optional) Custom S3 endpoint for MinIO or other services

**Note:** While the environment variables are available, each application needs to be configured individually to use S3 storage. This typically involves:

1. Installing S3 plugins or using built-in S3 support
2. Configuring media paths to use S3 URLs or mount points
3. Setting up S3FS or similar FUSE filesystem to mount S3 as a local directory

#### 4. Using S3FS (Recommended Approach)

For easier integration, you can mount the S3 bucket as a filesystem using s3fs-fuse:

**On the Minikube EC2 Instance:**

```bash
# Install s3fs
sudo apt-get update
sudo apt-get install s3fs

# Create mount point
sudo mkdir -p /mnt/s3-media

# Mount S3 bucket (using IAM role credentials automatically)
sudo s3fs dev-my-project-media /mnt/s3-media -o iam_role=auto,allow_other,use_cache=/tmp

# Make mount persistent (add to /etc/fstab)
echo "dev-my-project-media /mnt/s3-media fuse.s3fs _netdev,iam_role=auto,allow_other,use_cache=/tmp 0 0" | sudo tee -a /etc/fstab
```

Then update your application paths to use `/mnt/s3-media` instead of local storage.

#### 5. IAM Role Requirements

The EC2 instance must have an IAM role with the following permissions:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "s3:GetObject",
        "s3:PutObject",
        "s3:DeleteObject",
        "s3:ListBucket"
      ],
      "Resource": [
        "arn:aws:s3:::your-bucket-name",
        "arn:aws:s3:::your-bucket-name/*"
      ]
    }
  ]
}
```

This is automatically configured when using the Terraform stack.

#### 6. Cost Considerations

**Storage Costs (us-east-1):**
- Standard: ~$23/TB/month
- Intelligent-Tiering: ~$23/TB/month (frequent), ~$12.50/TB/month (infrequent)
- Standard-IA: ~$12.50/TB/month
- Glacier: ~$3.60/TB/month

**Data Transfer:**
- Data IN: Free
- Data OUT to Internet: $0.09/GB (first 10TB)
- Data OUT to EC2 (same region): Free

**Recommendation:** Use Intelligent-Tiering for automatic cost optimization. It monitors access patterns and moves objects to the most cost-effective tier.

### Alternative: MinIO for Development

For development or testing, you can use MinIO as an S3-compatible storage:

```bash
# Install MinIO on Kubernetes
kubectl apply -f https://raw.githubusercontent.com/minio/minio/master/docs/orchestration/kubernetes/minio-standalone-deployment.yaml

# Update values.yaml
s3:
  enabled: true
  bucketName: "media"
  region: "us-east-1"
  endpoint: "http://minio-service:9000"
  usePathStyle: true
```

## Support

For issues specific to individual applications, consult their documentation:

- [SABnzbd Docs](https://sabnzbd.org/wiki/)
- [Sonarr Wiki](https://wiki.servarr.com/sonarr)
- [Radarr Wiki](https://wiki.servarr.com/radarr)
- [Bazarr Wiki](https://wiki.bazarr.media/)
- [Jellyfin Docs](https://jellyfin.org/docs/)

For S3 integration:
- [AWS S3 Documentation](https://docs.aws.amazon.com/s3/)
- [s3fs-fuse GitHub](https://github.com/s3fs-fuse/s3fs-fuse)

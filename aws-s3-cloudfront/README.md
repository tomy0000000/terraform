# AWS S3 + CloudFront

Perfect for static file hosting

## Usage

1. Create `terraform.tfvars`

```terraform
project-name                    = ""
bucket-region                   = ""
bucket-name                     = ""
cloudfront-origin-shield-region = ""
domain                          = ""
```

2. Initialize

```shell
tofu init
```

3. Plan

```shell
tofu plan
```

4. Apply

```shell
tofu apply
```

# Multi-tenant AKS with Traffic Manager, AGIC and TLS termination

## Prerequisites
* Variable `dns_zone_id`: Azure DNS Zone ID to integrate with
* Variables `subscription_id` and `tenant_id`
* File `certificate.pfx`: X.509 wildcard certificate matching Azure DNS zone name

## Provision Azure resources
```sh
terraform plan -out main.tfplan -var-file main.tfvars; terraform apply main.tfplan
```

## Provision Kubernetes manifests
Grab `hostname` and `ssl_certificate_name` from the Terraform output and execute for every tenant:
```sh
HOSTNAME=$hostname APPGW_SSL_CERT=$ssl_certificate_name kubectl apply -k k8s/<tailspin|wingtip>
```
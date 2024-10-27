# Introduction

This document serves as a detailed overview of my approach and solutions to the [technical challenge](tech_challenge.md) presented as part of the application process. The challenge provided an exciting opportunity to showcase my technical skills, problem-solving abilities, and approach to delivering efficient, reliable solutions. 

In the following sections, I will outline my methodology, the tools and technologies I used, and the steps I took to address the specific requirements of the challenge. I approached this task with a focus on best practices, scalability, and code quality to ensure a robust outcome. 

I look forward to any feedback you may have and hope this documentation reflects my commitment to excellence and continuous learning.

# Prerequisits

Here’s a structured **Prerequisites** section in Markdown:

---

## Prerequisites

To ensure a smooth setup and execution of the challenge, please complete the following steps:

1. **Install Minikube and Enable Ingress Add-On**  
   - Install [Minikube](https://minikube.sigs.k8s.io/docs/start/) on your local environment.
   - Enable the Ingress add-on in Minikube:
     ```bash
     minikube addons enable ingress
     ```

2. **Install and Configure GitHub Runner**  
   - Set up a [self-hosted GitHub runner](https://docs.github.com/en/actions/hosting-your-own-runners/about-self-hosted-runners) to allow GitHub Actions to run workflows in your environment.

3. **Install Docker Buildx and Terraform**  
   - Install Docker Buildx to enable advanced build options for Docker images:
     ```bash
     # Docker Buildx installation steps
     ```
   - Install [Terraform](https://www.terraform.io/downloads) for managing infrastructure as code.

4. **Generate Kubernetes Credentials for Terraform User**  
   - Generate a public key and CSR (Certificate Signing Request) for the Terraform user.
   - Create the CSR in Kubernetes:
     ```yaml
     #example of csr.yaml
     apiVersion: certificates.k8s.io/v1
     kind: CertificateSigningRequest
     metadata:
       name: terraform
     spec:
       request: <BASE64_CSR>
       signerName: kubernetes.io/kube-apiserver-client
       expirationSeconds: 86400  # one day
       usages:
       - client auth
     ```

     ```bash
     kubectl apply -f csr.yaml
     # approve
     kubectl certificate approve terraform
     ```
   - Bind the Terraform user to the required cluster roles:
     ```yaml
     # example cluster role binding
     apiVersion: rbac.authorization.k8s.io/v1
     kind: ClusterRoleBinding
     metadata:
       creationTimestamp: null
       name: admin-binding-terraform
     roleRef:
       apiGroup: rbac.authorization.k8s.io
       kind: ClusterRole
       name: cluster-admin
     subjects:
     - apiGroup: rbac.authorization.k8s.io
       kind: User
       name: terraform
     ```
     ```bash
     kubectl apply -f cluster_role_binding.yaml
     ```
    - Download the client certificate
    ```bash
    kubectl get csr terraform -o jsonpath='{.status.certificate}' | base64 -d > tf.crt
    ```
    - Use the downloaded client certificate, client key, and cluster CA certificate (~/.minikube/ca.crt) in the terraform provider block (step 6.).

5. **Create Personal Access Token for Docker Hub**  
   - Generate a personal access token on [Docker Hub](https://hub.docker.com/) to allow access for image pushes.

6. **Store Credentials in GitHub Secrets**  
   - Store the following credentials securely as GitHub Secrets to enable GitHub Actions to access them:
     - `client_certificate`: Client certificate for Kubernetes
     - `client_key`: Client key for Kubernetes
     - `cluster_ca_certificate`: Cluster CA certificate for Kubernetes
     - `dockerhub_username`: Docker Hub username
     - `dockerhub_password`: Docker Hub password

Ensure all the above steps are completed before proceeding with the challenge to avoid setup issues. 

# Landscape

## Landscape diagram

![alt text](images/landscape.png "Title")

# Application

![alt text](images/application.png "Title")

# Deployment

![alt text](images/deployments.png "Title")

# Notes

- it would be better to deploy the workload with the gitos approach, using Flux or ArgoCD.
- PostgreSQL username and password is hardcoded in the backend python app. An secrets manager/vault should be used instead
- local terraform backend is used, and the tfstate files are stored in _work folder of the actions-runner. A better solution should used to store the tfstate file, which is more secure and provide the lock feature.
  - I tried to store it in Kubernetes using the kubernetes backend, but after I lost an hour or two, because I couldn't handle the authentication, I switched to local.
- Certificate for for terraform is expiring in 24 hours. This could be, either automated or issued with longer expiration time.
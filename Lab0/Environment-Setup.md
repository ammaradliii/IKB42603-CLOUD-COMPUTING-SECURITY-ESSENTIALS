# IKB42603 Lab 0 - Environment Setup Report

## Objective

Set up and verify the local environment required for IKB42603 lab activities: Docker, AWS CLI, Kubernetes tooling, OAuth Toolkit, and LocalStack. The purpose of this Lab 0 exercise is to ensure that all supporting tools are correctly installed and communicating before they are used in later cloud, container, and Kubernetes activities. Completing these checks at the beginning helps identify configuration problems early and creates a known working baseline for the rest of the course.

## Learning Outcomes

Upon completing this lab, the learner can:

- Verify that Docker is installed and can run containers.
- Confirm that AWS CLI, `kind`, `kubectl`, and `oathtool` are available.
- Check that LocalStack is healthy and its AWS-compatible services are reachable.
- Confirm that a local Kubernetes cluster is accessible and its node is ready.
- Distinguish between an installation check, such as displaying a version, and a functional check, such as starting a container or contacting a service endpoint.
- Interpret basic command output to determine whether a local service or cluster is available for use.

## Environment

Commands were executed in a Kali Linux terminal. The setup uses local development services rather than a remote cloud environment: Docker provides the container runtime, LocalStack emulates selected AWS services, and kind creates a Kubernetes cluster using Docker containers. This combination allows the lab exercises to be performed consistently on one machine.

| Component | Verified version/status |
| --- | --- |
| Docker | 28.5.2+dfsg4 |
| AWS CLI | 2.36.9 |
| kind | v0.23.0 |
| kubectl client | v1.36.3 |
| Kustomize | v5.8.1 |
| OATH Toolkit | 2.6.14 |
| LocalStack | Pro 2026.7.0; healthy on port 4566 |
| Kubernetes node | `ccse-control-plane`, Ready, v1.30.0 |

## Step-by-Step Implementation

### Step 1: Install and verify Docker

The supplied cheatsheet gives the following Linux installation commands:

```bash
curl -fsSL https://get.docker.com | sh
sudo usermod -aG docker $USER
```

After logging out and back in to apply the group change, verify Docker:

Check the Docker installation:

```bash
docker --version
```

The terminal reported Docker version `28.5.2+dfsg4`. This result confirms that the Docker client is installed and that the command is available in the terminal's `PATH`.

Run the Docker test container:

```bash
sudo docker run --rm hello-world
```

Docker displayed **"Hello from Docker!"**, confirming that the client contacted the Docker daemon, downloaded the image, started the container, and received its output. This is a stronger verification than a version check because it confirms that the Docker daemon is running and able to pull and execute an image. The `--rm` option removes the test container when it exits, preventing unused test containers from accumulating.

Result: **Passed**.

### Step 2: Install and verify AWS CLI

Install AWS CLI v2 on Linux as specified in the cheatsheet:

```bash
curl 'https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip' -o awscliv2.zip
unzip awscliv2.zip && sudo ./aws/install
```

Run:

```bash
aws --version
```

The terminal reported `aws-cli/2.36.9` with Python 3.14.6. AWS CLI is required to interact with AWS-compatible services from the command line. In subsequent exercises, it can be configured to send requests to LocalStack instead of an external AWS account when local testing is needed.

Result: **Passed**.

### Step 3: Install and verify kind and kubectl

Install the Kubernetes tools:

```bash
sudo snap install kubectl --classic
curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.23.0/kind-linux-amd64
chmod +x ./kind && sudo mv ./kind /usr/local/bin/kind
```

Run:

```bash
kind --version
kubectl version --client
```

The terminal reported `kind v0.23.0`, `kubectl v1.36.3`, and Kustomize `v5.8.1`. The `kind` tool is responsible for creating and managing local Kubernetes clusters, while `kubectl` is used to inspect and manage Kubernetes resources. Kustomize is included with the Kubernetes client and supports configuration customisation in later deployment work.

Result: **Passed**.

### Step 4: Install and verify helper tools

OpenSSL is already included on Linux. Install the OATH Toolkit with:

```bash
sudo apt install oathtool
```

Trivy does not need a local installation because Lab 4 runs it in Docker:

```bash
docker run --rm aquasec/trivy image <name>
```

Run:

```bash
oathtool --version
```

The terminal reported OATH Toolkit `2.6.14`. The OAuth Toolkit provides the `oathtool` command, which can generate and validate one-time passwords. Its availability confirms that the environment is prepared for lab tasks involving authentication mechanisms or time-based one-time password concepts.

Result: **Passed**.

### Step 5: Start and verify LocalStack

Start LocalStack (the first run downloads its image):

```bash
docker run -d --name localstack -p 4566:4566 localstack/localstack
```

Query the LocalStack health endpoint:

```bash
curl -4 http://localhost:4566/_localstack/health
```

The JSON response showed the configured AWS-compatible services, including S3, Lambda, DynamoDB, IAM, and STS, as `available`. It also identified LocalStack as version `2026.7.0`. A response from `localhost:4566` proves that the LocalStack service is running locally and accepting requests on its standard edge port. The service status is important because AWS CLI commands directed at LocalStack depend on this endpoint being available.

Result: **Passed**.

### Step 6: Create and verify the kind Kubernetes cluster

Create the course cluster:

```bash
kind create cluster --name ccse
```

Check the cluster and its nodes:

```bash
kubectl cluster-info --context kind-ccse
kubectl get nodes
```

The Kubernetes control plane and CoreDNS were reachable. The `ccse-control-plane` node was in the `Ready` state and reported Kubernetes version `v1.30.0`. Specifying `--context kind-ccse` ensures that `kubectl` communicates with the intended local kind cluster. The ready status shows that the node has joined the cluster successfully and is able to accept workloads when required.

Result: **Passed**.

### Step 7: Configure and verify AWS CLI access to LocalStack

The Lab 0 setup cheatsheet uses dummy credentials for LocalStack, then stores the LocalStack endpoint option in `$EP`:

```bash
aws configure set aws_access_key_id test
aws configure set aws_secret_access_key test
aws configure set region us-east-1
EP='--endpoint-url=http://localhost:4566'
```

Confirm that AWS CLI can send an AWS-compatible request to LocalStack:

```bash
aws $EP sts get-caller-identity
```

The command returned the LocalStack test identity, including account ID `000000000000` and ARN `arn:aws:iam::000000000000:user/myuser`. This confirms more than the AWS CLI installation: it shows that the CLI can reach the configured LocalStack endpoint and receive a valid response from its STS service.

Result: **Passed**.

## Commands Used

```bash
curl -fsSL https://get.docker.com | sh
sudo usermod -aG docker $USER
docker --version
sudo docker run --rm hello-world
curl 'https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip' -o awscliv2.zip
unzip awscliv2.zip && sudo ./aws/install
aws --version
sudo snap install kubectl --classic
curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.23.0/kind-linux-amd64
chmod +x ./kind && sudo mv ./kind /usr/local/bin/kind
kind --version
kubectl version --client
sudo apt install oathtool
docker run --rm aquasec/trivy image <name>
oathtool --version
docker run -d --name localstack -p 4566:4566 localstack/localstack
curl -4 http://localhost:4566/_localstack/health
kind create cluster --name ccse
kubectl cluster-info --context kind-ccse
kubectl get nodes
aws configure set aws_access_key_id test
aws configure set aws_secret_access_key test
aws configure set region us-east-1
EP='--endpoint-url=http://localhost:4566'
aws $EP sts get-caller-identity
```

## Screenshots

### Docker version

![Docker version verification](1.png)

### Docker hello-world test

![Docker hello-world verification](2.png)

### AWS CLI version

![AWS CLI version verification](3.png)

### Kubernetes tooling versions

![kind and kubectl version verification](4.png)

### OAuth Toolkit version

![OATH Toolkit version verification](5.png)

### LocalStack health response

![LocalStack health verification](6.png)

### Kubernetes cluster and node status

![Kubernetes cluster and node verification](7.png)

### AWS CLI LocalStack identity check

![AWS CLI STS identity verification](8.png)

## Challenges Encountered

No setup errors were recorded in the supplied evidence. The main requirement was to confirm each dependency separately and to use the correct Kubernetes context, `kind-ccse`, when checking the cluster. This distinction matters because a computer may have `kubectl` installed but still be unable to communicate with the required cluster if the wrong context is selected or the cluster is not running.

The LocalStack health response is lengthy because it reports many services at once. Rather than checking every field manually, the important outcome is that the requested endpoint responded successfully and listed the required services as `available`.

## Lessons Learned

- A version check confirms that a command-line tool is installed, while a functional command such as `docker run --rm hello-world` verifies that the service is operational.
- LocalStack health checks provide a quick way to confirm that the required AWS-compatible services are available locally; an AWS CLI STS request verifies that the CLI can use that local endpoint.
- Kubernetes verification should include both cluster connectivity and node readiness.
- A successful local setup depends on the relationship between tools: kind requires Docker to run its cluster nodes, `kubectl` requires a valid cluster context, and AWS-compatible local testing requires a healthy LocalStack endpoint.
- Recording actual versions and command output makes the lab report reproducible and helps troubleshoot differences between machines later.

## References

- IKB42603 Lab 0 Environment Setup Cheatsheet, `IKB42603_Lab0_Environment_Setup_Cheatsheet.pdf`.
- Docker documentation: https://docs.docker.com/
- Kubernetes documentation: https://kubernetes.io/docs/
- LocalStack documentation: https://docs.localstack.cloud/

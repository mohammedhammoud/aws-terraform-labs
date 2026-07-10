# 05 - VPC Basics

This lab creates a basic public VPC network with Terraform using Floci as a local AWS emulator.

The Terraform code was written manually to make sure I understand how VPCs, subnets, internet gateways, route tables, security groups, public IPs, and EC2 instances connect to each other.

## Resources

- VPC: `05-vpc-basics`
- Public subnet: `05-vpc-basics-public`
- Internet Gateway: `05-vpc-basics-igw`
- Public route table: `05-vpc-basics-public-rt`
- Route table association from the public subnet to the public route table
- Security group: `05-vpc-basics-web-sg`
- EC2 instance using the Floci Amazon Linux 2023 image
- Inline `user_data` script that starts a simple HTTP server on port 80
- Terraform outputs for the network and EC2 instance

## What I learned

- How to create a VPC with Terraform
- How CIDR blocks work at a basic level
- How to create a subnet inside a VPC
- Why resources like EC2 instances are placed in subnets, not directly in the VPC
- How to attach an Internet Gateway to a VPC
- How a route table controls where subnet traffic goes
- How `0.0.0.0/0` represents all IPv4 traffic
- How a route table association connects a subnet to a route table
- Why a subnet becomes public when it has a route to an Internet Gateway
- How a security group controls inbound and outbound traffic for a resource
- How to allow HTTP traffic on port 80
- How to assign a public IP to an EC2 instance

## Network flow

```text
Internet
-> Internet Gateway
-> Public route table
-> Public subnet
-> Security Group
-> EC2 instance
```

## Public subnet path

```text
VPC 10.0.0.0/16
-> Public subnet 10.0.1.0/24
-> Route table association
-> Public route table
-> 0.0.0.0/0 route
-> Internet Gateway
```

This means the subnet has a route for internet traffic.

## Security group rules

The web security group allows:

```text
Inbound:
tcp/80 from 0.0.0.0/0

Outbound:
all protocols to 0.0.0.0/0
```

This means the EC2 instance can receive HTTP traffic on port 80 and can make outbound connections.

## Boot flow

```text
Terraform creates EC2 instance
-> Floci starts a Docker container for the instance
-> user_data runs inside the container
-> script creates /tmp/index.html
-> script starts a Python HTTP server on port 80
```

## Test

Run from this project directory:

```sh
../../tools/tf.sh plan
../../tools/tf.sh apply
```

Check the EC2 instance:

```sh
aws ec2 describe-instances \
  --query "Reservations[].Instances[].{InstanceId:InstanceId,PublicIp:PublicIpAddress,PrivateIp:PrivateIpAddress,State:State.Name}"
```

Check that the EC2 container is running:

```sh
docker ps --format "table {{.Names}}\t{{.Ports}}\t{{.Status}}"
```

Example container name:

```text
floci-ec2-i-0ed8b1e86f3553137
```

Check the HTTP server from inside the container:

```sh
docker exec -it <container-name> bash
cat /tmp/index.html
curl http://127.0.0.1:80
```

Expected output:

```text
hello from 05-vpc-basics
```

## Commands

Run from this project directory:

```sh
../../tools/tf.sh plan
../../tools/tf.sh apply
../../tools/tf.sh destroy
```

## Notes

This lab uses Floci, not real AWS.

Floci runs EC2 instances as local Docker containers. The design still follows the real AWS networking pattern:

```text
VPC -> subnet -> route table -> Internet Gateway -> security group -> EC2
```

In real AWS, the EC2 instance would get a private IP from the subnet range, for example:

```text
10.0.1.x
```

In Floci, the private IP may come from Docker networking instead, for example:

```text
172.17.0.x
```

Floci may expose only SSH from the EC2 Docker container to the host machine. This means `curl http://127.0.0.1` from the host may not reach the EC2 web server even if the server is running correctly inside the container.

The important distinction is:

```text
The Internet Gateway gives the VPC a door to the internet.
The route table tells subnet traffic to use that door.
The route table association connects the subnet to that route table.
The security group controls what traffic is allowed into and out of the EC2 instance.
The public IP makes the EC2 instance addressable from outside the VPC.
```

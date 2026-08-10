# Network NAT Egress

Terraform lab for testing outbound internet access from a private EC2 instance through a NAT Gateway.

The lab creates:

- a VPC
- a public subnet
- a private subnet
- an Internet Gateway
- a NAT Gateway with an Elastic IP
- separate public and private route tables
- one private EC2 instance without a public IP
- a Security Group allowing outbound traffic

## Routing

The public subnet has:

```text
0.0.0.0/0 -> Internet Gateway
```

The private subnet has:

```text
0.0.0.0/0 -> NAT Gateway
```

The NAT Gateway is placed in the public subnet and uses an Elastic IP.

The traffic path is:

```text
private EC2
  -> private route table
  -> NAT Gateway
  -> public subnet
  -> Internet Gateway
  -> internet
```

## Private EC2

The EC2 instance:

- is placed in the private subnet
- has no public IP
- has no inbound Security Group rules
- allows outbound traffic

The instance cannot be reached directly from the internet but can initiate outbound connections through the NAT Gateway.

## Test

I was too lazy to set up another way to verify outbound connectivity, so I used Webhook.site to confirm that the private EC2 instance could reach the internet through the NAT Gateway.

The EC2 `user_data` sends an HTTP request to a Webhook.site endpoint:

```bash
curl -s "https://webhook.site/<id>?source=nat-lab"
```

The request appeared successfully on Webhook.site.

The source IP matched the NAT Gateway's public Elastic IP.

This verified that the private EC2 instance reached the internet through:

```text
private EC2 -> NAT Gateway -> Internet Gateway
```

even though the EC2 instance itself had no public IP.

## Key takeaways

- A private EC2 instance does not need a public IP to access the internet.
- A NAT Gateway provides outbound internet access for private subnets.
- The NAT Gateway must be placed in a public subnet.
- The public subnet needs a route to an Internet Gateway.
- The private subnet routes internet-bound traffic to the NAT Gateway.
- External services see the NAT Gateway's public IP, not the EC2 instance's private IP.
- NAT allows outbound connections but does not make the private EC2 directly reachable from the internet.

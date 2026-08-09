# Network Routing

Terraform lab for understanding routing inside an AWS VPC.

The lab creates:

- one VPC
- one public subnet
- one private subnet
- one Internet Gateway
- separate route tables
- one public EC2 instance
- one private EC2 instance
- Security Groups for HTTP and SSH

## Routing

Each route table automatically contains:

```text
10.0.0.0/16 → local
```

This allows traffic between resources inside the VPC.

The public route table also contains:

```text
0.0.0.0/0 → Internet Gateway
```

The private route table only has the local route.

## Tests

### Public EC2 internet access

The public EC2 has a public IP and its subnet has:

```text
0.0.0.0/0 → IGW
```

Test:

```bash
curl http://<public-ip>
```

Result:

```text
hello from 24-network-routing
```

The IGW route was then removed with:

```hcl
route = []
```

The same curl timed out.

This verified that a public IP and open Security Group are not enough without a route to the Internet Gateway.

### Private EC2

The private EC2 has no public IP and could not be reached directly from the local machine:

```bash
curl http://<private-ip>
```

The request failed.

### Local VPC routing

The public EC2 was accessed over SSH:

```bash
ssh -i ~/.ssh/id_rsa ec2-user@<public-ip>
```

From there:

```bash
curl http://<private-ip>
```

Result:

```text
hello from 24-network-routing
```

Traffic used:

```text
public EC2
→ route table
→ 10.0.0.0/16 → local
→ private EC2
```

This verified that subnets inside the same VPC can communicate without an IGW or NAT Gateway.

### Security Group vs routing

The private EC2 Security Group allows HTTP only from the public EC2 Security Group.

When the private ingress rule was removed:

```hcl
ingress = []
```

the internal curl timed out even though the local route still existed.

This verified:

```text
route table = network path
Security Group = permission to use that path
```

### Longest prefix match

A temporary route was added:

```text
1.1.1.1/32 → IGW
```

The route table contained:

```text
1.1.1.1/32 → IGW
10.0.0.0/16 → local
0.0.0.0/0 → IGW
```

For destination `1.1.1.1`, both `/32` and `/0` match, but `/32` wins because AWS uses longest prefix match.

## Key takeaways

- subnet type is determined by routing
- every route table gets the VPC local route
- route tables choose paths based on destination IP
- `0.0.0.0/0` is the default route
- public IP + IGW route are both required for direct internet access
- Security Groups do not replace routing
- the most specific matching route wins

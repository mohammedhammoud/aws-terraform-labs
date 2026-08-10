# Network SG vs NACL

Terraform lab for comparing AWS Security Groups and Network ACLs.

The lab creates:

- a VPC
- a public subnet
- an Internet Gateway
- a public route table
- one EC2 instance running a simple HTTP server
- a Security Group
- a custom Network ACL

## Security Group

The EC2 Security Group allows:

- HTTP on port `80`
- all outbound traffic

Security Groups are stateful.

Return traffic for an allowed connection is automatically permitted.

## Network ACL

The custom NACL allows:

- inbound TCP `80`
- outbound TCP `1024-65535`

The outbound range is required because NACLs are stateless.

A client connects using an ephemeral source port:

```text
client:52522 -> EC2:80
```

The response therefore returns to that port:

```text
EC2:80 -> client:52522
```

This was verified on macOS with:

```bash
lsof -iTCP -n -P | grep curl
```

## Tests

### Baseline

```bash
curl http://<public-ip>
```

Result:

```text
hello from 25-network-sg-vs-nacl
```

### Outbound port 80 only

The NACL egress rule was changed to allow only TCP port `80`.

`curl` hung because return traffic was sent to the client's ephemeral port instead of destination port `80`.

### Explicit deny

An inbound deny rule for TCP `80` with rule number `50` was added before the allow rule with rule number `100`.

HTTP traffic was blocked.

NACL rules are evaluated from the lowest rule number and the first matching rule decides the result.

### Deny ephemeral ports

An outbound deny rule for `1024-65535` with rule number `180` was placed before the allow rule with rule number `200`.

Return traffic was blocked and `curl` hung.

### Security Group deny behavior

HTTP ingress was removed from the Security Group while the NACL still allowed TCP `80`.

Traffic was blocked because Security Groups have no explicit deny rules. Traffic without a matching allow rule is implicitly denied.

## Key takeaways

- Security Groups operate at the resource/ENI level.
- NACLs operate at the subnet level.
- Security Groups are stateful.
- NACLs are stateless.
- Security Groups contain allow rules only.
- NACLs support both allow and deny rules.
- NACL return traffic must be explicitly allowed.
- TCP clients use ephemeral source ports.
- NACL rules are evaluated by rule number, lowest first.
- Routing decides where traffic goes; SGs and NACLs decide whether traffic is allowed.

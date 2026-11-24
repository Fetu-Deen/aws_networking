# AWS Networking: Custom VPC, Bastion, NAT, ALB & Auto Scaling

Hands-on AWS networking projects from the **CoderCo DevOps Academy**. Everything here was built by hand in the AWS console (region **us-east-2 / Ohio**), tested, broken, debugged and documented.

| # | Assignment | What it covers |
|---|---|---|
| 1 | [VPC & Networking](./assignment-1-vpc-networking/) | Custom VPC, public/private subnets, IGW, NAT Gateway, route tables, bastion host |
| 2 | [Application Load Balancer + ASG](./assignment-2-alb-asg/) | ALB, target group, health checks, Auto Scaling Group, Route 53, HTTPS with ACM |

Assignment 2 is built on top of the network from Assignment 1.

---

## Final architecture

```
User
 │  https://coderco-mini-alb.fetudeen.com
 ▼
Route 53 (Alias A record)  ←  domain registered at Porkbun, nameservers delegated to Route 53
 │
 ▼
Internet Gateway
 │
 ▼
Application Load Balancer (public subnets)
 │  HTTPS:443 (ACM cert)  /  HTTP:80
 ▼
Target group: coderco-tg  (HTTP:80, health check on "/")
 │
 ▼
Auto Scaling Group: coderco  →  EC2 instances in PRIVATE subnets (no public IPs)
                                 │
                                 └─ outbound only (dnf install at boot) → NAT Gateway → IGW

Admin access:  Laptop ──SSH──▶ Bastion (public subnet) ──SSH──▶ Private EC2
```

## Repo structure

```
aws_networking/
├── README.md
├── assignment-1-vpc-networking/
│   ├── README.md
│   └── screenshots/
└── assignment-2-alb-asg/
    ├── README.md
    ├── user-data.sh
    └── screenshots/
```

## Key takeaways

1. **A subnet's route table makes it public or private, not its name.** `0.0.0.0/0 → IGW` means public, `0.0.0.0/0 → NAT` means private with outbound internet, and no default route means isolated.
2. **The ALB reaches instances by private IP.** App servers never need a public IP.
3. **Users never go through the NAT.** Inbound traffic goes IGW → ALB → instance. The NAT is only for the instance's own outbound traffic.
4. **The ASG's health check and the target group's health check are separate.** Turn on ELB health checks in the ASG, or broken apps never get replaced.
5. **The ALB's error code tells you which layer broke.** 503 = no healthy targets, 502 = the app refused the connection, 504 = timeout (usually a security group).

## Cleanup

NAT Gateways, ALBs and Elastic IPs bill by the hour even when idle. Delete them when you're done testing.

---

**Fetudin Mohammed (Fatu)** · [LinkedIn](https://linkedin.com/in/fetudeen) · [GitHub](https://github.com/Fetu-Deen)

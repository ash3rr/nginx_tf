#  Nginx server deployed into AWS using Terraform

Current solution has ingress rules for http and https, I've also added open ingress rules as well as SSH. (Commented out for testing)
The inbound rule restricts to two known IP address only, so the host is not reachable publicly unless you meet this criteria.

Configuration management using a tool like Ansible would be better to install and configure nginx, rather than userdata. 

In a production environment depending on expected requests, and whether this was expected to be used publicly you would probably need to protect against malicious attacks (denial of service) and use something like cloudflare, configure a load balancer, create and configure the SSL certificate, and maybe a reverse proxy.

resource "aws_security_group" "observer_sg" {
  name        = "${var.project_name}-observer-sg"
  description = "Allow SSH, Grafana, and Prometheus only from bastion"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description     = "SSH from bastion SG"
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.bastion_sg.id]
  }

  ingress {
    description     = "Grafana from bastion SG"
    from_port       = 3000
    to_port         = 3000
    protocol        = "tcp"
    security_groups = [aws_security_group.bastion_sg.id]
  }

  ingress {
    description     = "Prometheus from bastion SG"
    from_port       = 9090
    to_port         = 9090
    protocol        = "tcp"
    security_groups = [aws_security_group.bastion_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-observer-sg"
  }
}

resource "aws_security_group_rule" "node_exporter_from_observer" {
  type                     = "ingress"
  from_port                = 9100
  to_port                  = 9100
  protocol                 = "tcp"
  security_group_id        = aws_security_group.private_sg.id
  source_security_group_id = aws_security_group.observer_sg.id
  description              = "Allow observer to scrape node_exporter"
}

resource "aws_instance" "observer" {
  ami                    = var.custom_ami_id
  instance_type          = var.instance_type
  subnet_id = module.vpc.public_subnets[0]
  associate_public_ip_address = true
  vpc_security_group_ids = [aws_security_group.observer_sg.id]
  key_name               = var.key_name

  root_block_device {
    volume_size           = 10
    volume_type           = "gp3"
    delete_on_termination = true
  }

  user_data = <<-EOF
              #!/bin/bash
              set -e

              sudo systemctl start docker
              sudo systemctl enable docker

              sudo mkdir -p /opt/prometheus

              sudo tee /opt/prometheus/prometheus.yml > /dev/null <<PROMCFG
              global:
                scrape_interval: 15s

              scrape_configs:
                - job_name: "node_exporter"
                  static_configs:
                    - targets:
                        - "${aws_instance.private_nodes[0].private_ip}:9100"
                        - "${aws_instance.private_nodes[1].private_ip}:9100"
                        - "${aws_instance.private_nodes[2].private_ip}:9100"
                        - "${aws_instance.private_nodes[3].private_ip}:9100"
                        - "${aws_instance.private_nodes[4].private_ip}:9100"
                        - "${aws_instance.private_nodes[5].private_ip}:9100"
              PROMCFG

              sudo docker run -d \
                --name prometheus \
                --restart unless-stopped \
                -p 9090:9090 \
                -v /opt/prometheus/prometheus.yml:/etc/prometheus/prometheus.yml \
                prom/prometheus

              sudo docker run -d \
                --name grafana \
                --restart unless-stopped \
                -p 3000:3000 \
                grafana/grafana
              EOF

  tags = {
    Name = "${var.project_name}-observer"
    Role = "prometheus-grafana-observer"
  }
}

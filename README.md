## 전체 아키텍처

![image](https://github.com/Junseokee/Infra-demo/assets/102888442/5aaa0ecb-1387-4d6e-9255-2fc90125ffae)

 
## 네트워크 

DMZ VPC만 Public으로 구성 APP과 Share VPC는 DMZ VPC와 TransitGW를 통해 연결

트래픽 흐름

웹에서 접근(HTTPS) → IGW → External ALB(HTTPS) → Nginx Instance(reverse proxy, HTTP) →

Internal ALB(HTTP) → Domain 주소 식별 후 Listener Rule로 TG 매핑 → EKS Service → Application



## Megatree Infra Terraform  코드

Terraform을 이용하여 내부 툴체인을 제외한 AWS 리소스 프로비저닝

megatree-regacy : 1차 local 개발 코드 (올인원, *LB&DB 리소스 제외)

- repo : https://github.com/KuberixEnterprise/megatree-infra/tree/main/terraform

megatree : Terraform Cloud 활용한 Workspace 분리

- repo : https://github.com/KuberixEnterprise/standard-architecture-template 

- Terraform Cloud : https://app.terraform.io/app/kuberix-org/workspaces?project=prj-j4hmPibwDEKh1Rdc 

아래와 같이 7개의 Workspace로 분리해 프로비저닝 시간 단축

중앙 집중화된 State, Variable 관리로 보안과 협업을 강화하고 프로젝트 전반적인 효율 향상

인프라 관리 복잡성과 오류 감소 및 VCS 연결을 통한 CI/CD 자동화 워크플로우

WorkSpace 실행 순서 : network(dmz, app, share) → routing → app-dmz → app-app → app-share 순으로 

실행해야 data 참조 가능

![image](https://github.com/Junseokee/Infra-demo/assets/102888442/ac0cf0ab-c48c-4ba3-85a9-cb52d47525ef)

--- 

## DMZ VPC
![image](https://github.com/Junseokee/Infra-demo/assets/102888442/cbacc321-2ff7-4c42-ab79-e73dc8455066)

설치환경

Spec

nginx-server : t3.small * 2

bastion-server : t3.small

Nginx conf

bastion 서버를 통해 nginx server 접근 → nginx server ssh 22 port만 허용

외부 도메인 주소로 미리 정의된 Internal LB로 프록시

새로 외부 도메인이 추가 될때마다 수정 필요.

코드

    user www-data;
    worker_processes auto;
    pid /run/nginx.pid;
    include /etc/nginx/modules-enabled/*.conf;
    
    events {
            worker_connections 768;
            # multi_accept on;
    }
    
    http {
        include /etc/nginx/mime.types;
        default_type application/octet-stream;
        sendfile on;
        keepalive_timeout 65;
        server_tokens off;
        access_log /var/log/nginx/access.log;
        error_log /var/log/nginx/error.log;
        server_names_hash_bucket_size 128;
        client_max_body_size 2000M;


    upstream ci {
        server internal-megatree-ci-alb-878441782.ap-northeast-2.elb.amazonaws.com:80; # CI 어플리케이션의 Internal ALB
    }

    upstream cd {
        server internal-megatree-cd-alb-799333082.ap-northeast-2.elb.amazonaws.com:80; # CD 어플리케이션의 Internal ALB
    }

    upstream app {
        server internal-megatree-app-alb-684006061.ap-northeast-2.elb.amazonaws.com:80; # 일반 어플리케이션의 Internal ALB
    }

    # CI 서브도메인 설정
    server {
        listen 80;
        server_name gitlab-megatree.kuberix.co.kr; # CI에 대한 서브도메인

        location / {
            proxy_pass http://ci;
            proxy_set_header Host $http_host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_http_version 1.1;
            proxy_set_header Upgrade $http_upgrade;
            proxy_set_header Connection "upgrade";
        }
    }

    server {
        listen 80;
        server_name argo-megatree.kuberix.co.kr; # CD에 대한 서브도메인
        location / {
            proxy_pass http://cd;
            proxy_set_header Host $http_host;
            proxy_http_version 1.1;
            proxy_set_header Upgrade $http_upgrade;
            proxy_set_header Connection "upgrade";
        }
    }
    # CD 서브도메인 설정
    server {
        listen 80;
        server_name grafana-megatree.kuberix.co.kr; # CD에 대한 서브도메인
        location / {
            proxy_pass http://cd;
            proxy_set_header Host $http_host;
            proxy_http_version 1.1;
            proxy_set_header Upgrade $http_upgrade;
            proxy_set_header Connection "upgrade";
        }
    }

    # 일반 어플리케이션 서브도메인 설정
    server {
        listen 80;
        server_name megatree.kuberix.co.kr; # 일반 어플리케이션에 대한 서브도메인

        location / {
            proxy_pass http://app;
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        }
    }
    server {
        listen 80 default_server; # HTTP 80 포트에서 리스닝, 기본 서버로 설정
        listen [::]:80 default_server ipv6only=on;

        # 서버 도메인 또는 IP
        server_name _;

        # 루트 디렉토리 및 인덱스 파일
        root /var/www/html;
        index index.html index.html index.nginx-debian.html;

        # 위치 블록 예시
        location / {
            try_files $uri $uri/ =404; # 요청된 URI에 해당하는 파일이나 디렉토리가 없는 경우 404 반환
        }
    }
    }
    
---

## APP VPC

![image](https://github.com/Junseokee/Infra-demo/assets/102888442/a2692c24-3308-46ef-99c3-0ca587cfc876)

### 설치환경

Spec

CD NodeGroup 
- instance : c5.xlarge * 3

APP NodeGroup
- instance : m5.xlarge * 1 



버전

- EKS 1.28
- Chart version
- aws-load-balancer-controller : v2.7.0
- argo-cd : v2.9.6
- open-telemetry : 0.93.0
- grafana : 10.2.3
- loki : 2.9.2
- mimir : 2.11.0
- tempo : 2.3.1
- Database
- MariaDB 10.11.6



설치 가이드

TargetGroupBinding

1. 어플리케이션 배포
2. aws-load-balancer-controller에 내장되어 함께 배포된 TargetGroupBinding 리소스 배포
3. TG 자동 생성

![image](https://github.com/Junseokee/Infra-demo/assets/102888442/c66b9048-676c-42c6-8ddc-9abfdfe86500)

4. Internal ALB에서 Listener Rule을 TG과 연결 → Actions를 생성된 TG으로 지정
* Health checks 오류 발생시 Success codes를 200 → 200-399로 변경 (301로 반환하는 경우 존재)

5. Conditions 설정
- HTTP Host Header is {외부 도메인}
- Path Pattern is /*

![image](https://github.com/Junseokee/Infra-demo/assets/102888442/ae95e6e6-5cf0-4dea-ba88-6be0f984688b)

--- 

### ArgoCD

argo-values.yaml

    server:
      service:
        type: NodePort
    
    configs:
      cm:
        accounts.develop: apiKey, login
      rbac:
        policy.csv: |
          p, role:dev, applications, *, */*, allow
          p, role:dev, projects, *, *, allow
          p, role:dev, repositories, *, *, allow
          g, develop, role:dev
      secret:
        argocdServerAdminPassword: "kuberix"
      params:
        server.insecure: true

argo-tgb.yaml

    apiVersion: elbv2.k8s.aws/v1beta1
    kind: TargetGroupBinding
    metadata:
      labels:
        ingress.k8s.aws/stack: megatree-argocd
      name: argo-tgb
      namespace: argo
    spec:
      ipAddressType: ipv4
      serviceRef:
        name: argo-argocd-server
        port: 80
      targetGroupARN: arn:aws:elasticloadbalancing:ap-northeast-2::targetgroup/megatree-argo-tg/{}
      targetType: instance



### 모니터링 구성 Grafana (OpenTelemetry + Mimir + loki + Tempo)

Chart 구성은 Standard 아키텍처와 유사하므로 아래를 참조

Mimir, Loki, Tempo의 리소스를 상황에 맞게 조절
모니터링 구축 예시는 비공개
Grafana Mimir + OpenTelemetry
Grafana loki + OpenTelemetry
Grafana Tempo + OpenTelemetry

- Grafana CloudWatch DataSource 연결
![image](https://github.com/Junseokee/Infra-demo/assets/102888442/2404fd9e-5ef5-46c0-95b3-b859cc3605b6)

CloudWatch 접근 Policy와 Role을 생성하고 신뢰관계를 nodegroup Role에 선언 (Terraform code에 포함)

Grafana Data Source 추가를 선택하고 생성한 Role ARN 등록

app-app/grafana_cloudwatch_role.tf

    resource "aws_iam_policy" "grafana_cloudwatch_policy" {
      name        = "grafana_watch"
      path        = "/"
      description = "grafana_cloudwatch_policy"
      policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
          {
            Sid    = "AllowReadingMetricsFromCloudWatch"
            Effect = "Allow"
            Action = [
              "cloudwatch:DescribeAlarmsForMetric",
              "cloudwatch:DescribeAlarmHistory",
              "cloudwatch:DescribeAlarms",
              "cloudwatch:ListMetrics",
              "cloudwatch:GetMetricData",
              "cloudwatch:GetInsightRuleReport"
            ]
            Resource = "*"
          },
          {
            Sid    = "AllowReadingLogsFromCloudWatch"
            Effect = "Allow"
            Action = [
              "logs:DescribeLogGroups",
              "logs:GetLogGroupFields",
              "logs:StartQuery",
              "logs:StopQuery",
              "logs:GetQueryResults",
              "logs:GetLogEvents"
            ]
            Resource = "*"
          },
          {
            Sid    = "AllowReadingTagsInstancesRegionsFromEC2"
            Effect = "Allow"
            Action = [
              "ec2:DescribeTags",
              "ec2:DescribeInstances",
              "ec2:DescribeRegions"
            ]
            Resource = "*"
          },
          {
            Sid      = "AllowReadingResourcesForTags"
            Effect   = "Allow"
            Action   = "tag:GetResources"
            Resource = "*"
          }
        ]
      })
    }
    
    resource "aws_iam_role" "grafana_role" {
      name       = "grafana_role"
      depends_on = [aws_iam_role.eks_nodegroup_role]
      assume_role_policy = jsonencode({
        Version = "2012-10-17",
        Statement = [
          {
            Action = "sts:AssumeRole",
            Principal = {
              "AWS" : aws_iam_role.eks_nodegroup_role.arn
            },
            Effect = "Allow",
          }
        ]
      })
    }
    
    # Attach the Policy to the Role
    resource "aws_iam_role_policy_attachment" "example_attach" {
      role       = aws_iam_role.grafana_role.name
      policy_arn = aws_iam_policy.grafana_cloudwatch_policy.arn
    }
    
참조 : https://grafana.com/docs/grafana/latest/datasources/aws-cloudwatch/

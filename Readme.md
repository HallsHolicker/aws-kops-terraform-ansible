# Install Kops by Terraform & Ansible

가시다님의 PKOS 스터디를 진행하면서 작성을 합니다.

스터디는 AWS에서 KOPS를 이용하여 쿠버네티스를 설치하고 테스트를 진행합니다.

스터디에서는 Cloudformation을 이용하여 KOPS 배포를 진행하기에 Terraform & ansible로 배포하는 스크립트를 작성해 봤습니다.

## Prerequirement

스크립트를 시작하기 전에 AWS에서 다음의 작업을 필요합니다.

1. Route53에 DNS 도메인 ( KOPS Cluster Name으로 사용됨 )
2. 구축 및 테스트의 편의성을 위해 administraotr 권한을 가진 IAM User 생성
3. 생성된 유저에 Access Key 생성
4. Default VPC는 삭제

생성된 AWS Access Key와 Secret Key는 Ansible에서 사용이 됩니다.

## Terraform

Terraform을 이용하여 다음 서비스들을 배포합니다.

1. VPC
2. KOPS Client용 EC2
3. KOPS에서 k8s 설정을 저장할 S3


## Ansible

Ansible을 이용하여 다음 작업들이 가능합니다.

### kops.yaml 
생성된 AWS Access Key 및 Secre Key는 다음 위치에 작성합니다.
아래의 파일은 .gitignore로 git에는 올라가지 않으니 만드셔야 합니다.

roles/kops/vars/.secret
```
AWS_AccessKey: <생성된 Access Key>
AWS_SecretKey: <생성된 Secret Key>
```

1. install-kops : KOPS Client Ec2에 kubectl, kops 설치
2. create-cluster : KOPS를 이용한 K8S 생성
3. info-cluster: K8S 정보 ( KOPS(Cluster Info, Instance Group, Instance, Node IP), K8S(Cluster Info, Nodes, pods) )
4. delete-cluster : 생성된 K8S 삭제
5. install-externaldns : External DNS Addon 설치
6. install-awslbcontroller : AWS Load Balancer Controller Addon 설치
7. update-kops : Kops 설정 업데이트 ( 업데이트에 사용되는 변수들은 다음 경로의 파일을 사용합니다. roles/kops/vars/update.yaml)

   A. workerNodeSize : Worker Node Size 변경
      * Worker Node Size 변경은 다음값들을 변경후에 실행하면 됩니다.
      ```
      targetZone: nodes-ap-northeast-2a
      workerMinSize: 1
      workerMaxSize: 1
      ```
   B. nodeLocalDNSCache: Node Local DNS Cache 설정
     * Node Local DNS Cach는 다음값을 변경후에 실행하면 됩니다.
     ```
     nodeLocalDNSCache: true or false
     ```
   C. maxPod: Max Pod 변경 ( 예정 )

8. install-harbor : Harbor 설치
  - region의 ACM에 인증서가 미리 발급되어 있어야 합니다.
  - Aws Load Balancer Controller 가 설치 되어 있어야 합니다.
  - ExternalDNS 가 설치 되어 있어야 합니다.

9. install-gitlab : Gitlab 설치
  - region의 ACM에 인증서가 미리 발급되어 있어야 합니다.
  - Aws Load Balancer Controller 가 설치 되어 있어야 합니다.
  - ExternalDNS 가 설치 되어 있어야 합니다.

10. install-argocd : Argocd 설치
  - region의 ACM에 인증서가 미리 발급되어 있어야 합니다.
  - Aws Load Balancer Controller 가 설치 되어 있어야 합니다.
  - ExternalDNS 가 설치 되어 있어야 합니다.

## 실행 순서

1. Terraform으로 AWS 프로비저닝 진행
2. 실행후 나온 EC2 Public IP 확인
3. Ansible playbook 실행 (* 주의사항 : IP 마지막에 ,를 꼭 써줘야 합니다.)
   ```
   예>
   ansible-playbook --private-key=<ec2 key pair location> -i ec2-user@<terraform에서 확인한 ip>, kops.yaml
   ```

## 주의 사항
Cluster 생성과 삭제를 빠르게 진행하면 AWS의 내부 DNS에서 도메인 갱신에 시간이 걸려 Cluster 생성이 되어도 Validate가 제대로 되지 않는 현상이 발생합니다.

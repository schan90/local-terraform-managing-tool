# TERRAFORM-MANAGING-TOOL ( _tf-tools )
ver : beta_v0.9.8
===
목적: 
- 테라폼 각 배포환경을 workspace(env) 사용하여 분리
- 다양한 검증 로직을 활용하여 휴먼에러 최소화,일관성/통일성 유지, 관리 및 효율성 증대
- 추후 terragrunt 연동
  

PRE-REQUIRED 
> environment ( 범용 리눅스 환경 : amazon-linux2 기준 )

>> bash --version 4.x

>> sed --version 4.x (gnu-sed)

>> aws --version(aws-cli) 2.x ( V2  aws profile 환경변수 활용)

===
Test 환경 >
  - macOS ( ventura )
  - linux ( amazon linux2 )

====  
 ./_tf.sh < terraform-cli cmd >
1. terraform workspace 활용하여 tfvars 파일 상의 ENV 값 사용
2. terrafom-cli cmd 2차 가공하여 반복작업을 줄이고 기존 명령어를 확장하여 사용


--
#### usage-ex >
#### ./_tf.sh
 > arg 없을 경우 단계별 문답으로 수행

#### ./_tf.sh validate
#### ./_tf.sh init
#### ./_tf.sh plan
#### ./_tf.sh apply 
#### ./_tf.sh deploy





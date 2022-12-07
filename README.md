# TERRAFORM-MANAGING-TOOL ( _tf-tools )
ver : beta_v0.9.8
===
목적: 
- 테라폼 각 배포환경을 workspace(env) 사용하여 분리
- 다양한 검증 로직을 활용하여 휴먼에러 최소화,일관성/통일성 유지, 관리 및 효율성 증대
- 추후 terragrunt 및 기타 cli 커맨드 2차 가공하여 편의성 증대 및 휴먼에러 방지
  

## PRE-REQUIRED :

```
동작환경 : 범용리눅스 환경 (amazon-linux2 기준)
> bash --version 4.x
> sed --version 4.x (gnu-sed)
> aws --version(aws-cli 2.x ) : V1 사용시 삭제 후 V2로 셋업필요

TEST 환경
> amazon-linux2
> macOS 13.0.1

-------------------------------------
macOS 의 경우 아래 추가셋업 필요 :

> bash 업데이트 후 디폴트 쉘 변경 ( bash --version 4.x higher )
  brew install bash, which bash 사용하여 path 확인 ( ex: /opt/homebrew/bin/bash )
  루팅 후 (sudo -i) /etc/shells 마지막줄에 해당 shell 경로 추가 ( ex: /opt/homebrew/bin/bash )
  디폴트 쉘 변경 ( chsh -s /opt/homebrew/bin/bash )
  심볼릭링크 추가 (ln -s /opt/homebrew/bin/bash /usr/local/bin/bash)
  쉘 재실행 ( exec bash OR exec zsh ) 후 디폴트 bash 버전확인 ( which bash && /usr/bin/env bash --version )

> 리눅스호환 gnu-sed 설치후 디폴트로 변경

  brew 패키지 매니저로 gnu-sed 설치 및 설치 후 설치경로 확인
  : brew install gnu-sed ; brew info gnu-sed

  쉘 환경파일에(.bashrc 또는 .zhsrc) gnu-sed PATH 경로추가 > 
  echo 'export PATH="/opt/homebrew/opt/gnu-sed/libexec/gnubin:$PATH" ' >> ~/.zshrc
  OR
  echo 'export PATH="/opt/homebrew/opt/gnu-sed/libexec/gnubin:$PATH" ' >> ~/.bashrc

  쉘 재실행 ( exec bash OR exec zsh ) 후 which sed 로 디폴트 경로 적용확인 및 버전확용 ( which sed && sed --version )
  ex : /opt/homebrew/opt/gnu-sed/libexec/gnubin/sed

```

====  
 ./_tf.sh < terraform-cli cmd >
1. terraform workspace 활용하여 tfvars 파일 상의 ENV 값 사용
2. terrafom-cli cmd 2차 가공하여 반복작업을 줄이고 기존 명령어를 확장하여 사용


--
### usage-ex >
``` bash
#### ./_tf.sh
 > arg 없을 경우 단계별 문답으로 수행

#### ./_tf.sh validate
#### ./_tf.sh init
#### ./_tf.sh plan
#### ./_tf.sh apply 
#### ./_tf.sh deploy

테스트 시나리오 > 
EX0 & EX1 ;
EX1 ;

EX0 ) 사전에 정의된 S3 백엔드버킷이 없을 경우 .tfvars 에 값 설정 후, 백엔드버킷 생성 후 EX1 예제로 테스트 수행
    __PRJ0-S3-UNIQ ( 테라폼 S3 셋업예제 )
    ├── ++s3-unique-bk ( s3 템플릿 모듈 )
    │   ├── s3-main.tf
    │   ├── s3-outputs.tf
    │   └── s3-var.tf
    ├── _tf ( tf-tool 모듈 )
    │   ├── _init+chkvaild.sh
    │   ├── _tfact_apply+destory.sh
    │   ├── _tfact_inits.sh
    │   ├── _tfact_others.sh
    │   ├── _tfact_plan+vaild.sh
    │   ├── _tfact_state+import.s성
    │   ├── _tfact_wksp.sh
    │   ├── asking_about.sh
    │   └── env_wks.sh
    ├── _tf.sh ( tf-tool 실행스크립트 )
    ├── env
    │   ├── +mz-dev-s3-value.tfvars
    │   ├── +mz-qa-s3-value.tfvars
    ├── main.tf
    ├── outputs.tf
    ├── terra-conf.tf
    └── var-local.tf

EX1 ) 사전에 정의된 S3 백엔드버킷이 존재할 경우 *bknd.hcl 에 값설정 후 테스트

_PRJ-VPC-SUBNET ( 테라폼 VPC,SUBNET 셋업예제 )
├── _tf ( tf-tool 모듈 )
│   ├── _init+chkvaild.sh
│   ├── _tfact_apply+destory.sh
│   ├── _tfact_inits.sh
│   ├── _tfact_others.sh
│   ├── _tfact_plan+vaild.sh
│   ├── _tfact_state+import.sh
│   ├── _tfact_wksp.sh
│   ├── asking_about.sh
│   └── env_wks.s트
├── _tf.sh ( tf-tool 실행스크립트 )
├── env ( tfvars 데이터파일 및 backend 설정파일 )
│   ├── +mz-dev-vpc-value.tfvars
│   ├── +mz-qa-vpc-value.tfvars
│   ├── _mz-dev-s3-bknd.hcl
│   └── _mz-qa-s3-bknd.hc트
├── main.tf
├── outputs.tf
├── terra-conf.tf
└── var-local.tf


```


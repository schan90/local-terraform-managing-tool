# TERRAFORM-MANAGING-TOOL ( _tf-tools )
ver : beta_v0.9.8
===
목적: 
- terraform-cli 활용하여 각각 배포환경을 workspace(env) 사용하여 분리/구분
- 검증 로직을 커스터마이징 또는 컨벤션 정의하여 일관성/통일성 유지, 관리 효율성 증대
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

### usage-ex >
``` bash

============================================================================================================
 ./_tf.sh < terraform-cli cmd >

1. terraform workspace 활용하여 tfvars 파일 상의 ENV 값을 사용
ㄴ 해당 ENV 값에 따라 workspace 생성 후 해당 workspace 선택하여 tfstate 에 리소스 현황 기록

2. terrafom-cli cmd 2차 가공하여 반복작업을 줄이고 기존 명령어를 확장하여 사용

참고 : 
BACKEND 설정시 defailt wks 사용함. 
BACKEND 설정파일의 WORKSPACE 값은 변수화 할수 없음으로 default 설정 후 
추가로 tfvars 의 env 값으로 WORKSPACE SYNC 변경 단계를 거친다.

이후 해당 WORKSPACE 를 사용하여 리소스 현황을 해당환경 tfstate 에 기록함. 
추가로 작업진행시 해당 remote s3 환경값과 동일한 WORKSPACE 를 지정하면 각 환경별로 ( WORKSPACE ) 분리하여 배포/관리 용이함.

============================================================================================================

다운로드 후 실행권한 부여 후 아래와 같이 실행 :
ex> 
chmod 755 _tf.sh 

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
    │   ├── _tfact_state+import.sh
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


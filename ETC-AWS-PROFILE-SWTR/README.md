# ** aws-profile-switcher**

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
## REFERENCE :
```
AWS-CLI V2 profile 환경변수 및 set command & ETC ... 
```
> DOCs: [AWS-CLI V2 SET & PROFILE](https://awscli.amazonaws.com/v2/documentation/api/latest/reference/configure/set.html)

## How to install :

```
### step1. get this bash script ( ex> curl -LOs https://< bash-script 주소 > )
### step2. give exec & write permission & move this script to your home path ( ex> chmod 755 .aws-pf-swtchr.sh && mv .aws-pf-swtchr.sh ~/.aws-pf-swtchr.sh )
### step3. loading script in bashrc or zshrc ( ex> echo 'source ~/.aws-pf-swtchr.sh' >> ~/.bashrc OR echo 'source ~/.aws-pf-swtchr.sh' >> ~/.zshrc )
### step4. restart shell ( exec bash OR exec zsh )
### step5. using alias ( ex> aws-set or aws-key or aws-clear or aws-cli 등등 ... ) 
```
## Release-history  :
```
V1.2.7: 
Added> ReadME &Ver-display &ETC.

V1.2.3 :
Added > Validating Default Profile & message color Highlighting 

V1.2.2 :
fixed > grep&regex ERROR ( when just enter, no-input 예외처리 추가 )

===
V1.2.0 : 
Modify > 소스리팩토링 ( 가독성 개선 및 버전관리 )
>> 동적메뉴 리스팅& 컬러하일라이팅 ( 각 프로파일을 리스트번호로 선택 )
>> rc 환경 파일에서 분리 ( 별도의 스크립트를 쉘 rc 환경파일에서 로딩하여 사용 )
>> sed 커맨드 공통사용으로 개선 ( mac & linux )

===
beta ver 1.9 :
> aws-set 커맨드로 custom-profile 선택/변경시 해당 profile key 값으로 default 값 동적변경 
: ( 쉘 세션별로 독립적으로 서로다른 프로파일 사용가능)
> AWS CLI configure (VSCODE EXTENTION) 사용시 충돌해결
: ( AWS-PROFILE 리셋 및 예외처리 추가적용 ) 
> macOS & amazon-linux2 테스트 검증/ 확인 및 띄워쓰기 오류 및 오타수정

```
## Usage :

```
###  ~/.bashrc or ~/.zshrc ( 쉘 환경파일에서 로딩 : source ~/.aws-pf-swtchr.sh)
# 실행 권한 부여 후 파일경로를 ~/ 위치 후 아래와 같이 rc 환경파일 마지막 라인에 추가하여 쉘 실행시 로딩하여 사용
# 1. chmod 755 .aws-pf-swtchr.sh && mv .aws-pf-swtchr.sh ~/.aws-pf-swtchr.sh
# 2. echo 'source ~/.aws-pf-swtchr.sh' >> ~/.bashrc OR echo 'source ~/.aws-pf-swtchr.sh' >> ~/.zshrc (범용 리눅스 환경 : amazon-linux2 기준)
# 3. exec bash OR exec zsh ( 쉘 재실행 ) 
# 4. 아래 alias 사용하여 기능 실행 (ex> aws-set or aws-key or aws-clear or aws-cli 등등 ... )

############### alias & sub-main : 아래 alias cmd 로 주요기능 실행 #####경##########

alias aws-cli="aws --version | cut -d ' ' -f1 "
alias aws-list="cat ~/.aws/credentials | grep -o '\[[^]]*\]' | grep -Ev 'default' "
alias aws-config="aws configure list"
alias aws-key="aws_profile; aws configure list; "
alias aws-set="aws_set $1"
alias aws-clear="aws_clear; aws_profile; "
alias aws-sts="aws sts get-caller-identity"

aws_set ${DEFAULT_PF} ;

############### END ################################################

```
![aws-profile-swt4](https://user-images.githubusercontent.com/6235318/205489690-c2bda6bc-285e-4fd6-8496-d2a18c9540a5.png)



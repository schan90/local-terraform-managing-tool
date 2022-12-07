#!/usr/bin/env bash
##################################################################################################################################################################################################################################################################################################
# * AWS-KEY PROFILE SWITCHER ( * --  made by schan -- * )
#  ________  ___       __   ________                 ___  __    _______       ___    ___      ________  ________  ________  ________ ___  ___       _______           ________  ___       __   ___  _________  ________  ___  ___  _______   ________     
# |\   __  \|\  \     |\  \|\   ____\               |\  \|\  \ |\  ___ \     |\  \  /  /|    |\   __  \|\   __  \|\   __  \|\  _____\\  \|\  \     |\  ___ \         |\   ____\|\  \     |\  \|\  \|\___   ___\\   ____\|\  \|\  \|\  ___ \ |\   __  \    
# \ \  \|\  \ \  \    \ \  \ \  \___|_  ____________\ \  \/  /|\ \   __/|    \ \  \/  / /    \ \  \|\  \ \  \|\  \ \  \|\  \ \  \__/\ \  \ \  \    \ \   __/|        \ \  \___|\ \  \    \ \  \ \  \|___ \  \_\ \  \___|\ \  \\\  \ \   __/|\ \  \|\  \   
#  \ \   __  \ \  \  __\ \  \ \_____  \|\____________\ \   ___  \ \  \_|/__   \ \    / /      \ \   ____\ \   _  _\ \  \\\  \ \   __\\ \  \ \  \    \ \  \_|/__       \ \_____  \ \  \  __\ \  \ \  \   \ \  \ \ \  \    \ \   __  \ \  \_|/_\ \   _  _\  
#   \ \  \ \  \ \  \|\__\_\  \|____|\  \|____________|\ \  \\ \  \ \  \_|\ \   \/  /  /        \ \  \___|\ \  \\  \\ \  \\\  \ \  \_| \ \  \ \  \____\ \  \_|\ \       \|____|\  \ \  \|\__\_\  \ \  \   \ \  \ \ \  \____\ \  \ \  \ \  \_|\ \ \  \\  \| 
#    \ \__\ \__\ \____________\____\_\  \              \ \__\\ \__\ \_______\__/  / /           \ \__\    \ \__\\ _\\ \_______\ \__\   \ \__\ \_______\ \_______\        ____\_\  \ \____________\ \__\   \ \__\ \ \_______\ \__\ \__\ \_______\ \__\\ _\ 
#     \|__|\|__|\|____________|\_________\              \|__| \|__|\|_______|\___/ /             \|__|     \|__|\|__|\|_______|\|__|    \|__|\|_______|\|_______|       |\_________\|____________|\|__|    \|__|  \|_______|\|__|\|__|\|_______|\|__|\|__|
#                             \|_________|                                  \|___|/                                                                                     \|_________|                                                                      
# * Pre-Required >>> 
# - bash ver: 4.x higher ( bash --version ; which bash )
# ? amazon-linux2 default: bash ver 4.2 (OK)
# ! macOS default: bash ver 3.x ( Need to update to 4.x & set as Default Bash version )
# ref > https://itnext.io/upgrading-bash-on-macos-7138bd1066ba
#
# - sed ver: GNU sed ver 4.2 ( sed --version ; which sed )
# ? linux default: GNU sed ver 4.2.2  (OK)
# ! macOS default: POSIX sed based on unix (need to change as gnu-sed default using brew)
#  ㄴ gnu-sed for mac : /opt/homebrew/opt/gnu-sed/libexec/gnubin/sed
# ref > https://medium.com/@bramblexu/install-gnu-sed-on-mac-os-and-set-it-as-default-7c17ef1b8f64 
#
# Tested OS env (amazon-linux2 & macOS)
#   - macOS 13.0 ventura
#   - amazon-linux2 
# 
# How to install ( USAGE ) :
#
### ? step1. get this bash script ( ex> curl -LOs https://< bash-script 주소 > )
### ? step2. give exec & write permission & move this script to your home path ( ex> chmod 755 .aws-pf-swtchr.sh && mv .aws-pf-swtchr.sh ~/.aws-pf-swtchr.sh )
### ? step3. loading script in bashrc or zshrc ( ex> echo 'source ~/.aws-pf-swtchr.sh' >> ~/.bashrc OR echo 'source ~/.aws-pf-swtchr.sh' >> ~/.zshrc )
### ? step4. restart shell ( exec bash OR exec zsh )
### ? step5. using alias ( ex> aws-set or aws-key or aws-clear or aws-cli ... ETC. ) 

##################################################################################################################################################################################################################################################################################################
# git tag v1.3.0 / git push origin schan / master ( git config --local user.name "schan90" / git config --local user.email "qnas90@gmail.com" )
# git pull both HEAD / git push both HEAD  
swtr_ver="v1.3.0"
############ init for AWS credentials & config ##########
# 디폴트 프로파일 및 주요 변수 초기화
DEFAULT_PF="mz"              ### 원하는 디폴트 프로파일로 수정해서 사용 ###
PF="" ; KID="" ; KSEC="" ; RG="" ; PF_flag=false; NOINPUT_flag=false; 

# 키 값 조회 후 해당 값 리스트 배열 생성 및 반복 메세지 함수 생성
list_AWS_PROFILE=( $(cat ~/.aws/credentials | grep -o '\[[^]]*\]' | grep -Ev 'default'| xargs) ) ;

# ansi color code; cmd 차일드 프로세스에서 사용할 컬러 하이라이팅 코드 값 export 처리
export red="\e[1;31m" green="\e[1;32m"  yellow="\e[1;33m" grey="\e[0;37m" ;
export blue="\e[1;34m"  purple="\e[1;35m" cyan="\e[1;36m" reset="\e[m" ;

pf_msg()
{ 
  notset_chkr=$( echo -e $(aws configure list | grep 'profile' | grep '<not set>'|xargs|cut -d ' ' -f2) );
  default_chkr=$( echo -e $(aws configure list | grep 'profile' | grep "${DEFAULT_PF}"|xargs|cut -d ' ' -f2) );
  [[ "${notset_chkr}" == '<not' ]] && { echo -e "Using < DEFAULT > AWS-KEY... BUT, NOT using Custom PROFILE : < NOT SET >" ; return 0 ; } ;
  [[ "${default_chkr}" == "${DEFAULT_PF}" ]] && { echo -e "Using ${cyan}[DEFAULT]${reset} AWS-PROFILE...! ${grey}<${swtr_ver}>${reset}" ; return 0 ; }
  { echo -e "Using ${blue}[${AWS_PROFILE}]${reset} AWS-PROFILE as DEFAULT you Switched...! ${grey}[${swtr_ver}]${reset}" ; } ;

}
# 프로파일 현황 체크함수 정의
aws_profile() 
{
  if [[ -n $AWS_PROFILE ]]; then
    pf_msg ;
  elif [[ $(aws configure get default.region) != "cleared-region" ]]; then
    pf_msg ; 
    # echo -e "Using < Default > AWS-PROFILE ..."
  else
    echo -e "${yellow}None AWS-PROFILE ... ${reset}"
  fi
}

######################
# 프로파일 넘버링 리스트 함수 정의 및 컬러하일라이팅
numlist_profile()
{ 
  SELECTION=1
  ENTITIES=$(printf "%s\n" "${list_AWS_PROFILE[@]}") ;

  while read -r line; do
    echo -e "${red}$SELECTION)${reset} ${green}${line}${reset}"
    ((SELECTION++))
  done <<< "$ENTITIES"
  ((SELECTION--)) ;

  echo -e
  printf 'SELECT the AWS-KEY-PROFILE you want from the above list: '
  read -r opt
  if [[ ${opt} == "" || ${#opt} == 0 ]]; then
    echo -e "${red}You just Entered So NO INVAILD INPUT, Using Default-PROFILE~!${reset} \n" ; PF_flag=true ; NOINPUT_flag=true ;
  elif [[ $(seq 1 $SELECTION) =~ $opt ]]; then
    selcted=$( sed -n "${opt}p" <<< "$ENTITIES" ); PF=${selcted} ; PF_flag=true ;
  else
    echo -e "WRONG NUMBER OR INVAILD INPUT, BYE~!\n" ; PF_flag=false ; return 0 ;
  fi
  [[ ${NOINPUT_flag} != true ]] && { PF=$( echo -e "${PF:1}"|cut -d ']' -f1 ) ; } || { PF=${DEFAULT_PF} ; NOINPUT_flag=false ; } 
  # echo -e "##### ${opt} &&&& ${PF} ###### "
}

asking_pf()
{
  echo -en "
Which AWS-PROFILE do you want? : 

"
  numlist_profile ;
  [[ ${PF_flag} == false ]] && { return 0 ; }
  echo -en "
${yellow}in precessing ... wait for a while ... ${reset}

"
  [[ "${PF}" == "" ]] && { return 0 ; } || selc_pf="${PF}" ;

}

############### aws_set -> aws_set::conf ###############
#  프로파일 변경 및  해당 프로파일을  디폴트로 설정
aws_set::conf()
{
  KID=$(aws configure get ${1}.aws_access_key_id )
  KSEC=$(aws configure get ${1}.aws_secret_access_key)
  RG=$(aws configure get ${1}.region)

  aws configure set ${KID} default_access_key
  aws configure set ${KSEC} default_secret_key
  aws configure set default.region ${RG}
}
# 프로파일 유효성 검증 
aws_set()
{
  local pf=""; selc_pf="" ; 
  [[ "$1" == "" ]] && { asking_pf; pf="${selc_pf}"; } || pf="$1" ;
  [[ $( cat ~/.aws/credentials | grep "\[${pf}\]" ) ]] && { aws_clear; export AWS_PROFILE="${pf}"; aws_set::conf "${pf}"; } \
  || { echo -e -e "\n ***** ${yellow}INVALID PROFILE or DEFAULT set & Cleared PROFILE~!${reset} ***** "; aws_clear ; return 0 ;  }
  pf=""; PF="" ; PF_flag=false ;

  pf_msg;
}

############### aws_clear ->  aws_clear::conf #############
# 프로파일 환경변수 초기화 및 리전설정 리셋 ( 디폴트 및 모든 프로파일 변수를 초기화 하여 AWS-CLI 사용할 수 없음)
# 초기화 이후 다시 프로파일 사용하려면 aws-set 을 통해 프로파일 설정하면 해당 프로파일로 AWS-CLI 사용가능  
aws_clear::conf()
{
  # which sed
  ### for linux-bash sed
  # sed -i '/default_/d' ~/.aws/config 

  ### for mac-bash gnu-sed
  ## https://medium.com/@bramblexu/install-gnu-sed-on-mac-os-and-set-it-as-default-7c17ef1b8f64
  sed -i '/default_/d' ~/.aws/config ; 

  aws configure get ${PF}.aws_access_key_id | xargs -I {} aws configure set {} '' --profile ${PF} ;
  aws configure get ${PF}.aws_secret_access_key | xargs -I {} aws configure set {} '' --profile ${PF} ;
  aws configure set default.region "cleared-region" ; PF="" ;
}

aws_clear()
{
  aws_clear::conf ; export AWS_PROFILE= ; 
}

############### alias & sub-main 아래 cmd 로 주요기능 실행 ################

alias aws-cli="aws --version | cut -d ' ' -f1 "
alias aws-list="cat ~/.aws/credentials | grep -o '\[[^]]*\]' | grep -Ev 'default' "
alias aws-config="aws configure list"
alias aws-key="aws_profile; aws configure list; "
alias aws-set="aws_set $1"
alias aws-clear="aws_clear; aws_profile; "
alias aws-sts="aws sts get-caller-identity"

aws_set ${DEFAULT_PF} ;

############### END ################################################
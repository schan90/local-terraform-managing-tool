
# ~/.bashrc or ~/.zshrc
...

############ for aws credentials set: made by schan V1.9.0 ###########
DEFAULT_PF="mz"
PF="" ; KID="" ; KSEC="" ; RG="" ;

aws_profile() 
{
  if [[ -n $AWS_PROFILE ]]; then
    echo "Using ${AWS_PROFILE} AWS-PROFILE ..."
  elif [[ $(aws configure get default.region) != "cleared-region" ]]; then
    echo "Using Default-AWS-PROFILE ..."
  else
    echo "None AWS-PROFILE ..."
  fi
}

asking_pf()
{
  echo -n "
which AWS-PROFILE do you want? : 
$(cat ~/.aws/credentials | grep -o '\[[^]]*\]' | grep -Ev 'default')

If NO input & press ENTER, using ${DEFAULT_PF} ~!
reply-input >>> 
  "
  read REPLY
  [[ "${REPLY}" =  "" ]] && selc_pf="${DEFAULT_PF}" || selc_pf="${REPLY}"
  PF="${selc_pf}"
}

############### aws_set -> aws_confset ###############
aws_confset()
{
  KID=$(aws configure get ${1}.aws_access_key_id )
  KSEC=$(aws configure get ${1}.aws_secret_access_key)
  RG=$(aws configure get ${1}.region)

  aws configure set ${KID} default_access_key
  aws configure set ${KSEC} default_secret_key
  aws configure set default.region ${RG}
}

aws_set()
{
    [[ "$1" =  "" ]] && { asking_pf; pf="${PF}"; } || pf="$1"
    [[ $( cat ~/.aws/credentials | grep "\[${pf}\]" ) ]] && { aws_clear; export AWS_PROFILE=${pf}; aws_confset ${pf}; echo "using ${AWS_PROFILE} AWS-PROFILE ..."; PF=${AWS_PROFILE} ; } \
    || { echo -e "\n ***** Invalid profile name ***** \n"; aws_set; }

}

############### aws_clear ->  aws_confclear #############
aws_confclear()
{
  # which sed

  ### for linux-bash sed
  # sed -i '/default_/d' ~/.aws/config 

  ### for mac-bash gnu-sed
  ## https://medium.com/@bramblexu/install-gnu-sed-on-mac-os-and-set-it-as-default-7c17ef1b8f64
  
  #/opt/homebrew/opt/gnu-sed/libexec/gnubin/sed -i '/default_/d' ~/.aws/config  
  sed -i '/default_/d' ~/.aws/config
  
  aws configure get ${PF}.aws_access_key_id | xargs -I {} aws configure set {} '' --profile ${PF}
  aws configure get ${PF}.aws_secret_access_key | xargs -I {} aws configure set {} '' --profile ${PF}

  aws configure set default.region "cleared-region"
  # PF="${DEFAULT_PF}"
  PF=""
}

aws_clear()
{
  export AWS_PROFILE= ; aws_confclear ; 
  # aws_profile
}

############### alias ########

alias aws-key='aws_profile; aws configure list; '
alias aws-cli="aws --version | cut -d ' ' -f1 "
alias aws-set='aws_set $1 '
alias aws-clear='aws_clear '
alias aws-config='aws configure list'
alias aws-sts='aws sts get-caller-identity'
alias aws-list="cat ~/.aws/credentials | grep -o '\[[^]]*\]' | grep -Ev 'default' "

aws_profile

######################
# source ~/.zshrc or source ~/.bashrc
# exec zsh or exec bash 
#######

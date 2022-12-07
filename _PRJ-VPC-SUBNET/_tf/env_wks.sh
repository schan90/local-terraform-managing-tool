#!/usr/bin/env bash 
# which env

# chkVR=$1 ;
# echo -e "### chking : ${chkVR} ###" ;
#####################################################################################################################
## ? 현재 wksp(env) 변경 및 신규 설정 / 선택 활용
env_set()
{
  chENVWK=$1;
  [[ "${mtch_flag}" != true ]] && { echo -e "${yellow}### Creating & Switching Terrform-WorkSpace as like to ENV you input. ###${reset}"; }
  
  ###################### ref. ###########################################################################
  # - terraform workspace show, terraform workspace list, 
  # - terraform workspace new, terraform workspace select, terraform workspace delete
  #######################################################################################################

  terraform workspace new "${chENVWK}" ; terraform workspace select "${chENVWK}" ; 
  echo -en "
${yellow}
======== terraform workspace list =========
$(terraform workspace list ;)
===========================================
${reset}
"
}

#!/usr/bin/env bash 
# which env

# chkVR=$1 ;
# echo -e "### chking : ${chkVR} ###" ;
###################################################################

func_7()
{
  ### key : new-wks , value : func_7 ### 
  # echo " ### $@ ### "
  # echo " ${env_wk} "; echo " new-wks testing. BYE~ "; exit;
  newwk=$1
  [[ "${newwk}" != "" ]] && { terraform workspace new ${newwk} ;  }

  while [[ "${newwk}" == "" ]]; do echo -en "
############## NEW Terrform WORKSPACE ########################################
${red}Tell me the new Terrform WORKSPACE you want ~!  : ${reset}

############# ${yellow}REFER to Current WORKSPACE${reset} ####################
$( terraform workspace list ; )

If NO input, asking repeat ... !!! 
reply-input >>>  "
    read newwk
    [[ "${newwk}" != "" ]] && { terraform workspace new ${newwk} ;  }
  done

  echo "########################"
  terraform workspace list ; newwk="" ;
}

func_8()
{
  ### key : mv-wks , value : func_8 ### 
  # echo " ### $@ ### "
  mvwk=$1
  [[ "${mvwk}" != "" ]] && { terraform workspace select ${mvwk} ;  }

  while [[ "${mvwk}" == "" ]]; do echo -n "
############## Switching Terrform WORKSPACE ##################################
${red}Tell me the Terrform WORKSPACE to Switch ~!  : ${reset}

############# ${yellow}REFER to Current WORKSPACE${reset} ####################
$( terraform workspace list ; )

If NO input, asking repeat ... !!! 
reply-input >>>  "
    read mvwk
    [[ "${mvwk}" != "" ]] && { terraform workspace select ${mvwk} ;  }
  done

  echo "########################################################################"
  terraform workspace list ; mvwk="" ;
}

func_9()
{
  ### key : del-wks , value : func_9 ### 
  # echo " Not Defined this ACTION YET~. BYE~ "; exit;
  delwk=$1
  [[ "${delwk}" != "" ]] && { terraform workspace delete ${delwk} ;  }

  while [[ "${delwk}" == "" ]]; do echo -n "
############## Terrform WORKSPACE to DELETE ##################################
${red}Tell me the Terrform WORKSPACE to Delete ~!  : ${reset}

############# ${yellow}REFER to Current WORKSPACE${reset} ####################
$( terraform workspace list ; )

If NO input, asking repeat ... !!! 
reply-input >>>  "
    read delwk
    [[ "${delwk}" != "" ]] && { terraform workspace delete ${delwk} ;  }
  done

  echo "########################################################################"
  terraform workspace list ; delwk="" ;
}

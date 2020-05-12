#! /bin/sh
#
# Script to automate and simplify deployment of Atlassian test instances.

DEPLOYMENTS_DIR="$HOME/deployments";
DOWNLOADS_DIR="$HOME/tarfiles";

prep_directory(){

if [[ ! -d "${DEPLOYMENTS_DIR}" ]]
  then
    mkdir $DEPLOYMENTS_DIR
    echo "${DEPLOYMENTS_DIR} directory did not exist! I created it."
fi

if [[ ! -d "${DOWNLOADS_DIR}" ]]
  then
    mkdir $DOWNLOADS_DIR
    echo "${DOWNLOADS_DIR} directory did not exist! I created it."
fi
}


deploy_product() {

if [[ -z "${PRODUCT}" || -z "${VERSION}" ]]; then
  echo "\nNeed product and version : Run it as ./script.sh --product <product name> --version <version>\n"
  exit 1
fi  
    if [[ "$PRODUCT" == "jira-software" ]]
      then
        DOWNLOAD_URL="https://www.atlassian.com/software/jira/downloads/binary/atlassian-jira-software-${VERSION}.tar.gz"
    elif [[ "$PRODUCT" == "jira-core" ]]
      then
        DOWNLOAD_URL="https://www.atlassian.com/software/jira/downloads/binary/atlassian-jira-core-${VERSION}.tar.gz"
    elif [[ "$PRODUCT" == "jira-servicedesk" ]]
      then
        DOWNLOAD_URL="https://www.atlassian.com/software/jira/downloads/binary/atlassian-servicedesk-${VERSION}.tar.gz"
    else 
      echo "Unrecognized product. Bailing!"
      exit 1
    fi

  #DOWNLOAD_FILE="${DOWNLOAD_URL##*/}"
  
  #Get the downloaded file name from the download url
  DOWNLOAD_FILE=$(echo "${DOWNLOAD_URL}"  | sed 's/https\:\/\/www\.atlassian\.com\/software\/jira\/downloads\/binary\///g')

  if [[ ! -f "${DOWNLOADS_DIR}/${DOWNLOAD_FILE}" ]]
    then
      echo "\nDownloading ${DOWNLOAD_URL}...\n"
      wget_output=$(wget -P $DOWNLOADS_DIR $DOWNLOAD_URL)
      if [[ $? -ne 0 ]]; then
        echo "Error downloading file"
        exit
      else
        echo "\nDownloaded ${DOWNLOAD_FILE}.\n"
      fi
  fi
  echo "Installing ${PRODUCT} of version ${VERSION} to ${DEPLOYMENTS_DIR}..."
  # Move the untarred contents to a folder created and named as the version
  mkdir ${DEPLOYMENTS_DIR}/${VERSION} && tar -xzf ${DOWNLOADS_DIR}/atlassian-${PRODUCT}-${VERSION}.tar.gz -C ${DEPLOYMENTS_DIR}/${VERSION} --strip-components 1
  mkdir ${DEPLOYMENTS_DIR}/${VERSION}/jira-home
  JIRA_INSTALL_DIR=${DEPLOYMENTS_DIR}/${VERSION}

  # Update jira.application properties with jira home
  cat /dev/null > ${DEPLOYMENTS_DIR}/${VERSION}/atlassian-jira/WEB-INF/classes/jira-application.properties
  JIRA_HOME=${DEPLOYMENTS_DIR}/${VERSION}/jira-home; echo "jira.home=${JIRA_HOME}" >> ${DEPLOYMENTS_DIR}/${VERSION}/atlassian-jira/WEB-INF/classes/jira-application.properties

  # start Jira
  ${JIRA_INSTALL_DIR}/bin/start-jira.sh

}


while [[ $# > 1 ]]
do
opt="$1"

case $opt in
  --destroy)
    ACTION="destroy"
    shift
    ;;
  --name)
    NAME="$2"
    shift
    ;;
  --product)
    PRODUCT="$2"
    shift
    ;;
  --version)
    VERSION="$2"
    shift
    ;;
esac
shift
done

prep_directory
deploy_product


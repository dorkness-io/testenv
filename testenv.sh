#! /bin/sh
#
# Script to automate and simplify deployment of Atlassian test instances.

CONFIGFILE="$HOME/.testenv" 

firstrun()
{
  CONFIGFILE="$HOME/.testenv"
  echo "--------------------"
  echo "Hello!"
  echo "This appears to be your first time running the script"
  echo "Let's set a few variables for future use."
  echo "--------------------"
  # User input for variables with defaults
  echo "Define the directory where you'll be storing your deployments."
  read -p "[$HOME/deployments]: " DEPLOYMENTS_DIR
  DEPLOYMENTS_DIR=${DEPLOYMENTS_DIR:-$HOME/deployments}
  echo "...will use ${DEPLOYMENTS_DIR}\n\n"
  echo "Define the directory where you'll be storing product downloads."
  read -p "[$DEPLOYMENTS_DIR/downloads]" DOWNLOADS_DIR
  DOWNLOADS_DIR=${DOWNLOADS_DIR:-$DEPLOYMENTS_DIR/downloads}
  echo "...will use ${DOWNLOADS_DIR}"
  touch $CONFIGFILE
  echo "DEPLOYMENTS_DIR=${DEPLOYMENTS_DIR}" >> $CONFIGFILE
  echo "DOWNLOADS_DIR=${DOWNLOADS_DIR}" >> $CONFIGFILE 
  echo ""
  echo "Variable configuration complete! Please re-run the script."
  echo ""
  exit 0
}

deploy_product() {
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

  DOWNLOAD_FILE="${DOWNLOAD_URL##*/}"

  if [[ ! -f "${DOWNLOADS_DIR}/${DOWNLOAD_FILE}" ]]
    then
      echo "\nDownloading ${DOWNLOAD_URL}...\n"
      wget -P $DOWNLOADS_DIR $DOWNLOAD_URL
      echo "\nDownloaded ${DOWNLOAD_FILE}.\n"
    else
      echo "Already downloaded, moving on."
  fi
  
  echo "Installing ${NAME} to ${DEPLOYMENTS_DIR}..."

#  mkdir -p $DEPLOYMENTS_DIR/$NAME/install
#  mkdir -p $DEPLOYMENTS_DIR/$NAME/home
}

if [[ ! -f "${HOME}/.testenv" ]]
  then firstrun
fi

source $CONFIGFILE
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

deploy_product

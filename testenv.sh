#! /bin/bash
#
############

ACTION="Deploy"
DATABASE="PostgreSQL"
DEPLOYMENTS_DIR="$HOME/deployments"
DOWNLOADS_DIR="${DEPLOYMENTS_DIR}/downloads"

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

echo "Verb: ${ACTION}"
echo "Name: ${NAME}"
echo "Product: ${PRODUCT}"
echo "Version: ${VERSION}"


deploy_it () {
  if [[ ! -d "${DEPLOYMENTS_DIR}" ]]
    then
      mkdir -p $DEPLOYMENTS_DIR  
      echo "Deployments directory (${DEPLOYMENTS_DIR}) did not exist. Created it."
  fi

  if [[ "$PRODUCT" == "jira-software" ]]
    then
      echo "Product Match"
      DOWNLOAD_URL="https://www.atlassian.com/software/jira/downloads/binary/atlassian-jira-software-${VERSION}.tar.gz"
      echo $DOWNLOAD_URL
    fi

  DOWNLOAD_FILE="${DOWNLOAD_URL##*/}"

  if [[ ! -f "${DOWNLOADS_DIR}/${DOWNLOAD_FILE}" ]]
    then
      echo "Downloading ${DOWNLOAD_URL}..."
      wget -P $DOWNLOADS_DIR $DOWNLOAD_URL
      echo "Downloaded ${DOWNLOAD_FILE}."
    else
      echo "Already downloaded, moving on."
  fi
  
  echo "Installing ${NAME} to ${DEPLOYMENTS_DIR}..."

#  mkdir -p $DEPLOYMENTS_DIR/$NAME/install
#  mkdir -p $DEPLOYMENTS_DIR/$NAME/home
}

destroy_it () {
  exit
}

deploy_it () {
  exit
}


#!/bin/bash

PROJECTPATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT=${PROJECTPATH##/*/}
#COCOM="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"/../cocom
DHOME="/home/docker"

#SALT for the hash
SALT="TODO better salt"
# Set the password for the project as a hash of the salt and the project
PASSWORD=`echo $PROJECT $SALT| md5sum | cut -f1 -d" "`

FULL_BRANCH=$(git rev-parse --abbrev-ref HEAD)
# Lowecase the branch
FULL_BRANCH=`echo $FULL_BRANCH|awk '{print tolower($0)}'`
     BRANCH=${FULL_BRANCH##*/}
        TAG=$(git describe --always --tag)

echo "Launching $PROJECT"

docker run  -it -P -p 80 -p 8000:8000 \
  openco/$PROJECT-$BRANCH:$TAG
  --rm=false \
  --name $PROJECT \
  -e VIRTUAL_HOST=$PROJECT.openco.ca \
  -v $PROJECTPATH/snapmerge/media:/var/www/snapmerge/snapmerge/media
  -v $PROJECTPATH/snapmerge/database:/var/www/snapmerge/snapmerge/database
  -e DHOME=$DHOME \
  -e PROJECT="${PROJECT//./_}" \
  -e PASSWORD=$PASSWORD \
  -e VIRTUAL_PORT=80 \ 
  python snapmerge/manage.py runserver 0.0.0.0:8000 --settings=config.settings_local

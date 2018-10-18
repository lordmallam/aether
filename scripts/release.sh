#!/usr/bin/env bash
#
# Copyright (C) 2018 by eHealth Africa : http://www.eHealthAfrica.org
#
# See the NOTICE file distributed with this work for additional information
# regarding copyright ownership.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with
# the License.  You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing,
# software distributed under the License is distributed on an
# "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
# KIND, either express or implied.  See the License for the
# specific language governing permissions and limitations
# under the License.
#

release_app () {
    APP_NAME=$1
    COMPOSE_PATH=$2
    AETHER_APP="aether-${1}"

    echo "Building Docker image ${IMAGE_REPO}/${AETHER_APP}:${VERSION}"
    docker-compose -f $COMPOSE_PATH build \
        --build-arg GIT_REVISION=$TRAVIS_COMMIT \
        --build-arg VERSION=$VERSION \
        $APP_NAME

    echo "Pushing Docker image ${IMAGE_REPO}/${AETHER_APP}:${VERSION}"
    docker tag ${AETHER_APP} "${IMAGE_REPO}/${AETHER_APP}:${VERSION}"
    docker push "${IMAGE_REPO}/${AETHER_APP}:${VERSION}"

    if [[ $VERSION != "alpha" ]]
    then
        echo "Pushing Docker image ${IMAGE_REPO}/${AETHER_APP}:latest"
        docker tag ${AETHER_APP} "${IMAGE_REPO}/${AETHER_APP}:latest"
        docker push "${IMAGE_REPO}/${AETHER_APP}:latest"
    fi
}

release_process () {
    # Login in dockerhub with write permissions (repos are public)
    docker login -u $DOCKER_HUB_USER -p $DOCKER_HUB_PASSWORD

    # Try to create the aether network+volume if they don't exist.
    docker network create aether_internal      2>/dev/null || true
    docker volume  create aether_database_data 2>/dev/null || true

    # Build dependencies
    ./scripts/build_aether_utils_and_distribute.sh
    ./scripts/build_common_and_distribute.sh

    # Prepare Aether UI assets
    docker-compose build ui-assets
    docker-compose run   ui-assets build

    # Build docker images
    IMAGE_REPO='ehealthafrica'
    CORE_APPS=( kernel odk couchdb-sync ui )
    CORE_COMPOSE='docker-compose.yml'
    CONNECT_APPS=( producer )
    CONNECT_COMPOSE='docker-compose-connect.yml'

    for APP in "${CORE_APPS[@]}"
    do
        release_app $APP $CORE_COMPOSE
    done

    for CONNECT_APP in "${CONNECT_APPS[@]}"
    do
        release_app $CONNECT_APP $CONNECT_COMPOSE
    done
}

version_compare () {
    if [[ $1 == $2 ]]
    then
        return 0
    fi
    local IFS=.
    local i ver1=($1) ver2=($2)
    # fill empty fields in ver1 with zeros
    for ((i=${#ver1[@]}; i<${#ver2[@]}; i++))
    do
        ver1[i]=0
    done
    for ((i=0; i<${#ver1[@]}; i++))
    do
        if [[ -z ${ver2[i]} ]]
        then
            # fill empty fields in ver2 with zeros
            ver2[i]=0
        fi
        if ((10#${ver1[i]} > 10#${ver2[i]}))
        then
            return 1
        fi
        if ((10#${ver1[i]} < 10#${ver2[i]}))
        then
            return 2
        fi
    done
    return 0
}

# Usage: increment_version <version> [<position>]
increment_version() {
 local v=$1
 if [ -z $2 ]; then 
    local rgx='^((?:[0-9]+\.)*)([0-9]+)($)'
 else 
    local rgx='^((?:[0-9]+\.){'$(($2-1))'})([0-9]+)(\.|$)'
    for (( p=`grep -o "\."<<<".$v"|wc -l`; p<$2; p++)); do 
       v+=.0; done; fi
 val=`echo -e "$v" | perl -pe 's/^.*'$rgx'.*$/$2/'`
 echo "$v" | perl -pe s/$rgx.*$'/${1}'`printf %0${#val}s $(($val+1))`/
}

function travis-branch-commit() {
    UPDATE_DEVELOP_VERSION=0
    if [ $TRAVIS_BRANCH != "develop" ]
    then
        version_compare $1 $2
        COMPARE=$?
        if [[ ${COMPARE} = 0 ]]
        then
            msg "Starting versions (" ${VERSION} ", latest) release process ..."
            # release_process
            UPDATE_DEVELOP_VERSION=1
        elif [[ ${COMPARE} = 1 ]]
        then
            err "VERSION value is greater than the branch version"
            exit 1
        elif [[ ${COMPARE} = 2 ]]
        then
            err "VERSION value is less than the branch version"
            exit 1
        fi
    fi

    git checkout "$TRAVIS_BRANCH"

    NEW_VERSION=$(increment_version $FILE_VERSION 3)
    echo ${NEW_VERSION} > VERSION

    git add VERSION
    # make Travis CI skip this build
    git commit -m "Travis CI update [ci skip]"
    local remote=origin
    if [[ $GITHUB_TOKEN ]]; then
        remote=https://$GITHUB_TOKEN@github.com/$TRAVIS_REPO_SLUG
    fi
    if ! git push --quiet --follow-tags "$remote" "$TRAVIS_BRANCH" > /dev/null 2>&1; then
        err "failed to push git changes to" $TRAVIS_BRANCH
        exit 1
    fi

    if [ ${UPDATE_DEVELOP_VERSION} = 1 ]
    then
        echo "Updating develop branch version to " ${NEW_VERSION}
        git clone ${remote} --branch develop
        git checkout develop
        echo ${NEW_VERSION} > VERSION
        git add VERSION
        git commit -m "Version updated to ${NEW_VERSION} [ci skip]" #Skip travis build on develop commit
        if ! git push -b --quiet --follow-tags "$remote develop" > /dev/null 2>&1; then
            err "failed to push git changes to develop branch"
            exit 1
        fi
    fi
}

function msg() {
    echo "Versioning: $*"
}

function err() {
    msg "$*" 1>&2
}

# release version depending on TRAVIS_BRANCH/ TRAVIS_TAG
if [[ $TRAVIS_TAG =~ ^[0-9]+\.[0-9]+[\.0-9]*$ ]]
then
    VERSION=$TRAVIS_TAG
    FILE_VERSION=$TRAVIS_TAG

elif [[ $TRAVIS_BRANCH =~ ^release\-[0-9]+\.[0-9]+[\.0-9]*$ ]]
then
    VERSION=`cat VERSION`
    FILE_VERSION=${VERSION}

    IFS=- read -a ver_number <<< "$TRAVIS_BRANCH"
    BRANCH_VERSION=${ver_number[1]}
    # append "-rc" suffix
    VERSION=${VERSION}-rc

elif [[ $TRAVIS_BRANCH = "develop" ]]
then
    VERSION='alpha'
    FILE_VERSION=`cat VERSION`

else
    echo "Skipping a release because this branch is not permitted: ${TRAVIS_BRANCH}"
    exit 0
fi

echo "Release version:  $VERSION"
echo "Release revision: $TRAVIS_COMMIT"

travis-branch-commit ${FILE_VERSION} ${BRANCH_VERSION}

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
set -Eeuo pipefail

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
    echo "TOKEN: " ${GITHUB_TOKEN}
    if ! git checkout "$TRAVIS_BRANCH"; then
        err "failed to checkout $TRAVIS_BRANCH"
        return 1
    fi

    local v=$1
    echo ${v}
    VERSION=$(increment_version ${v} 3)
    echo ${VERSION} > VERSION
    cat VERSION

    if ! git add --all .; then
        err "failed to add modified files to git index"
        return 1
    fi
    # make Travis CI skip this build
    if ! git commit -m "Travis CI update [ci skip]"; then
        err "failed to commit updates"
        return 1
    fi
    # add to your .travis.yml: `branches\n  except:\n  - "/\\+travis\\d+$/"\n`
    local git_tag=SOME_TAG_TRAVIS_WILL_NOT_BUILD+travis$TRAVIS_BUILD_NUMBER
    if ! git tag "$git_tag" -m "Version increament tag from Travis CI build $TRAVIS_BUILD_NUMBER"; then
        err "failed to create git tag: $git_tag"
        return 1
    fi
    local remote=origin
    if [[ $GH_TOKEN ]]; then
        remote=https://$GITHUB_TOKEN@github.com/$TRAVIS_REPO_SLUG
    fi
    # if [[ $TRAVIS_BRANCH != master ]]; then
    #     msg "not pushing updates to branch $TRAVIS_BRANCH"
    #     return 0
    # fi
    if ! git push --quiet --follow-tags "$remote" "$TRAVIS_BRANCH" > /dev/null 2>&1; then
        err "failed to push git changes"
        return 1
    fi
}

function msg() {
    echo "travis-commit: $*"
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

travis-branch-commit ${FILE_VERSION}

# # Login in dockerhub with write permissions (repos are public)
# docker login -u $DOCKER_HUB_USER -p $DOCKER_HUB_PASSWORD

# # Try to create the aether network+volume if they don't exist.
# docker network create aether_internal      2>/dev/null || true
# docker volume  create aether_database_data 2>/dev/null || true

# # Build dependencies
# ./scripts/build_aether_utils_and_distribute.sh
# ./scripts/build_common_and_distribute.sh

# # Prepare Aether UI assets
# docker-compose build ui-assets
# docker-compose run   ui-assets build

# # Build docker images
# IMAGE_REPO='ehealthafrica'
# CORE_APPS=( kernel odk couchdb-sync ui )
# CORE_COMPOSE='docker-compose.yml'
# CONNECT_APPS=( producer )
# CONNECT_COMPOSE='docker-compose-connect.yml'

# for APP in "${CORE_APPS[@]}"
# do
#     release_app $APP $CORE_COMPOSE
# done

# for CONNECT_APP in "${CONNECT_APPS[@]}"
# do
#     release_app $CONNECT_APP $CONNECT_COMPOSE
# done

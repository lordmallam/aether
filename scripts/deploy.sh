#!/usr/bin/env bash
set -e

_recreate() {
    local directory="${1}"
    rm -fr "${directory}"
    mkdir -p "${directory}"
}

export APPS=( gather2-core gather2-odk-importer )

TAG="${TRAVIS_TAG}"
COMMIT="${TRAVIS_COMMIT}"
BRANCH="${TRAVIS_BRANCH}"
PR="${TRAVIS_PULL_REQUEST}"

if ! [ -n "${TAG}" ]; then
  echo "Not a git tag, tagging as: ${COMMIT}"
  TAG="${COMMIT}"
fi
export TAG

git clone "https://${GH_USER}:${GH_TOKEN}@github.com/eHealthAfrica/beanstalk-deploy" "${script_dir}/.ebextensions"

$(aws ecr get-login --region="${AWS_REGION}")
for APP in $APPS
do
	echo "Tagging "${DOCKER_IMAGE_REPO}/${APP}:${TAG}"
  docker tag "${APP}:latest" "${DOCKER_IMAGE_REPO}/${APP}:${TAG}"
  echo "Pushsing to ${DOCKER_IMAGE_REPO}/${APP}:${TAG}"
  docker push "${DOCKER_IMAGE_REPO}/${APP}:${TAG}"

  tmp_dir="tmp"
  _recreate "${tmp_dir}"
  envsubst < ${APP}/conf/Dockerrun.aws.json.tmpl > "${tmp_dir}/Dockerrun.aws.json"

  pushd "${script_dir}" >/dev/null
  zip_file="${tmp_dir}/deploy.zip"
  zip -r "${zip_file}" ".ebextensions" -x '*.git*'
  zip -j "${zip_file}" "${tmp_dir}"/* -x "${zip_file}"

  eb deploy "${APP}-dev" -l "${TAG}"
done
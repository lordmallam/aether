#!/usr/bin/env bash

set -Eeuox pipefail

source ./scripts/random_string.sh

export POSTGRES_PASSWORD=$(gen_random_string)

./scripts/generate-kubernetes-credentials.sh > helm/test-secrets.yaml
./scripts/kubernetes/install_minikube.sh
./scripts/kubernetes/install_helm.sh --version v2.8.1
./scripts/kubernetes/start_minikube.sh
./scripts/kubernetes/start_helm.sh
./scripts/kubernetes/install_secrets.sh
./scripts/kubernetes/start_cluster.sh ./helm/overrides/test
./scripts/kubernetes/run_tests.sh test_all
minikube stop

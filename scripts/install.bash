#!/bin/bash

set -euo pipefail

readonly DEBUG="${DEBUG:-unset}"
if [ "${DEBUG}" != unset ]; then
  set -x
fi

_fail() {
  printf "\033[0;31m==> %s\033[0m\n\n" "$1"
}

_success() {
  printf "\033[0;32m==> %s\033[0m\n\n" "$1"
}

_info() {
  printf "\033[1;33m==> %s\033[0m\n\n" "$1"
}

_user() {
  printf "\033[0;33m%s\033[0m" "$1"
}

_install_macos_common() {
  brew install talisman lefthook prettier shellcheck adr-tools aquasecurity/trivy/trivy
}

_install_macos_infra() {
  brew install tfenv kubectl kustomize kyverno kube-score actionlint
}

OS="$(uname)"
if [[ "${OS}" == "Darwin" ]]; then
  if ! command -v brew > /dev/null 2>&1; then
    _fail "Setup requires Homebrew, please install first: https://brew.sh"
    exit 1
  fi

  BUNDLE_NAME="${1:-common}"
  case "$BUNDLE_NAME" in
    "common") _install_macos_common ;;
    "infra") _install_macos_infra ;;
    *)
      _fail "Unknown bundle name, must be one of \"common\" (default), \"infra\"."
      exit 1
      ;;
  esac
else
  _fail "Installation is only supported on macOS (so far)."
  exit 1
fi

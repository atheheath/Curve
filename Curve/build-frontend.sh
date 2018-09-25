#!/bin/bash

# System:
#   1. Darwin or Linux
# Python:
#   1. version: 2.7.3+/3.1.2+ is recommended
#   2. other:
#       * python should belong to current user, otherwise virtualenv is required
#       * pip is required
# Node.js:
#   1. version: 4.7.0+ is recommended
#   2. other:
#       * npm is required

set -u
set -e

cd "$(dirname "$0")"
readonly G_ROOT_DIR=`pwd`
readonly G_WEB_DIR="${G_ROOT_DIR}/web"
readonly G_API_DIR="${G_ROOT_DIR}/api"
readonly G_VENV_DIR="${G_ROOT_DIR}/venv"

G_VERSION='none'
if [ -e .git ]; then
    G_VERSION=`git rev-parse HEAD`
fi
G_CONDA=''

PS1='$'

cutoff() {
    echo "============================================================="
}

check_web() {
    readonly BUILD_PATH="${G_WEB_DIR}/build"
    readonly BUILD_VERSION_FILE="${BUILD_PATH}/version"
    BUILD_VERSION=''
    if [ -e ${BUILD_VERSION_FILE} ]; then
        BUILD_VERSION=`cat ${BUILD_VERSION_FILE}`
    fi
    readonly DEPLOY_PATH="${G_API_DIR}/curve/web"
    readonly DEPLOY_VERSION_FILE="${DEPLOY_PATH}/version"
    DEPLOY_VERSION=''
    if [ -e ${DEPLOY_VERSION_FILE} ]; then
        DEPLOY_VERSION=`cat ${DEPLOY_VERSION_FILE}`
    fi

    if [ ${G_VERSION}x != 'x' -a ${G_VERSION}x == ${DEPLOY_VERSION}x ]; then
        return
    fi

    cutoff
    echo "build web..."
    if [ ${G_VERSION}x == 'x' -o ${G_VERSION}x != ${BUILD_VERSION}x ]; then
        cd ${G_WEB_DIR}
        npm install
        npm run build
        echo ${G_VERSION} > ${BUILD_VERSION_FILE}
    fi
    if [ -e ${DEPLOY_PATH} ]; then
        rm -rf ${DEPLOY_PATH}
    fi
    echo "web built."
    cutoff
}

check_web
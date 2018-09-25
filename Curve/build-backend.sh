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


help() {
    echo "${0} <start|start-dev|stop|reload|terminate|version>"
    exit 1
}

version() {
    if [ ${G_VERSION}x != 'x' ]; then
        cutoff
        echo "local Curve version: ${G_VERSION}"
        cutoff
    fi
}

check_py() {
    readonly VENV_VERSION_FILE="${G_VENV_DIR}/version"
    VENV_VERSION=''
    if [ -e ${VENV_VERSION_FILE} ]; then
        VENV_VERSION=`cat ${VENV_VERSION_FILE}`
    fi

    if [ ${G_VERSION}x != 'x' -a ${G_VERSION}x == ${VENV_VERSION}x ]; then
        return
    fi

    cutoff
    echo "deploy venv..."
    if [ ! -e "${G_ROOT_DIR}/venv" ]; then
        virtualenv --no-site-packages ${G_VENV_DIR}
    fi
    source ${G_VENV_DIR}/bin/activate
    pip install -r ${G_API_DIR}/requirements.txt
    if [ ! -e ${G_VENV_DIR}/bin/curve_uwsgi ]; then
        cd ${G_VENV_DIR}/bin
        ln -s uwsgi curve_uwsgi
        cd -
    fi
    echo ${G_VERSION} > ${VENV_VERSION_FILE}
    deactivate
    echo "venv deployed."
    cutoff
}

check_api() {
    readonly SWAGGER_UI_DIR="${G_API_DIR}/curve/api-doc"
    readonly SWAGGER_UI_VERSION_FILE="${SWAGGER_UI_DIR}/version"
    SWAGGER_UI_VERSION=''
    if [ -e ${SWAGGER_UI_VERSION_FILE} ]; then
        SWAGGER_UI_VERSION=`cat ${SWAGGER_UI_VERSION_FILE}`
    fi

    if [ ${G_VERSION}x != 'x' -a ${G_VERSION}x == ${SWAGGER_UI_VERSION}x ]; then
        return
    fi

    cutoff
    echo "deploy api..."
    cd ${G_ROOT_DIR}
    source ${G_VENV_DIR}/bin/activate
    pip install swagger-py-codegen==0.2.9
    swagger_py_codegen --ui --spec -s api/web_api.yaml api -p curve
    deactivate
    if [ -e ${G_API_DIR}/curve/web/swagger-ui ]; then
        rm -rf ${G_API_DIR}/curve/web/swagger-ui
    fi

    # rename static/swagger-ui to api-doc
    mv ${G_API_DIR}/curve/static/swagger-ui ${G_API_DIR}/curve/api-doc

    if [ -e ${G_API_DIR}/curve/api-doc/static/v1 ]; then
        rm -rf ${G_API_DIR}/curve/api-doc/static/v1
    fi

    mv ${G_API_DIR}/curve/static/v1/swagger.json ${G_API_DIR}/curve/api-doc
    rm -rf ${G_API_DIR}/curve/static

    # replaces default swagger-ui json reference location to new location
    patch ${G_API_DIR}/curve/api-doc/index.html ${G_API_DIR}/patch/api-doc.index.html.patch
    echo ${G_VERSION} > ${SWAGGER_UI_VERSION_FILE}
    echo "api deployed."
    cutoff
}

check_path() {
    mkdir -p ${G_API_DIR}/log
}

check_py
check_api
check_path

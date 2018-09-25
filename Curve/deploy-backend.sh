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

start() {
    if [ -e ${G_API_DIR}/uwsgi.pid ]; then
        PID=`cat ${G_API_DIR}/uwsgi.pid`
        if [ `ps -ef | fgrep curve_uwsgi | fgrep ${PID} | wc -l` -gt 0 ]; then
            echo "Curve is running."
            return
        fi
    fi

    if [ `ps -ef | fgrep curve_uwsgi | fgrep -v 'grep' | wc -l` -gt 0 ]; then
        ps -ef | fgrep curve_uwsgi | fgrep -v 'grep' | awk '{ print $2 }' | xargs kill -9
    fi
    echo "start Curve..."
    source ${G_VENV_DIR}/bin/activate
    cd ${G_API_DIR}
    ${G_VENV_DIR}/bin/curve_uwsgi uwsgi.ini
    echo "Curve started."
}

start-dev() {
    if [ -e ${G_API_DIR}/uwsgi.pid ]; then
        PID=`cat ${G_API_DIR}/uwsgi.pid`
        if [ `ps -ef | fgrep curve_uwsgi | fgrep ${PID} | wc -l` -gt 0 ]; then
            echo "Curve is running."
            return
        fi
    fi

    if [ `ps -ef | fgrep curve_uwsgi | fgrep -v 'grep' | wc -l` -gt 0 ]; then
        ps -ef | fgrep curve_uwsgi | fgrep -v 'grep' | awk '{ print $2 }' | xargs kill -9
    fi
    echo "start Curve..."
    source ${G_VENV_DIR}/bin/activate
    cd ${G_API_DIR}
    ${G_VENV_DIR}/bin/curve_uwsgi uwsgi-dev.ini
    echo "Curve started."
}

stop() {
    echo "stop Curve..."
    cd ${G_API_DIR}
    source ${G_VENV_DIR}/bin/activate
    [ -e uwsgi.pid ] && ${G_VENV_DIR}/bin/curve_uwsgi --stop uwsgi.pid
    echo "Curve stopped."
}

reload() {
    if [ -e ${G_API_DIR}/uwsgi.pid ]; then
        PID=`cat ${G_API_DIR}/uwsgi.pid`
        if [ `ps -ef | fgrep curve_uwsgi | fgrep ${PID} | wc -l` -gt 0 ]; then
            echo "reload Curve..."
            source ${G_VENV_DIR}/bin/activate
            cd ${G_API_DIR}
            ${G_VENV_DIR}/bin/curve_uwsgi --reload uwsgi.pid
            echo "Curve reloaded."
            return
        fi
    fi
    echo "clean Curve..."
    if [ `ps -ef | fgrep curve_uwsgi | fgrep -v 'grep' | wc -l` -gt 0 ]; then
        ps -ef | fgrep curve_uwsgi | fgrep -v 'grep' | awk '{ print $2 }' | xargs kill -9
    fi
    echo "start Curve..."
    source ${G_VENV_DIR}/bin/activate
    cd ${G_API_DIR}
    ${G_VENV_DIR}/bin/curve_uwsgi uwsgi.ini
    echo "Curve reloaded."
}

reload-dev() {
    if [ -e ${G_API_DIR}/uwsgi.pid ]; then
        PID=`cat ${G_API_DIR}/uwsgi.pid`
        if [ `ps -ef | fgrep curve_uwsgi | fgrep ${PID} | wc -l` -gt 0 ]; then
            echo "reload Curve..."
            source ${G_VENV_DIR}/bin/activate
            cd ${G_API_DIR}
            ${G_VENV_DIR}/bin/curve_uwsgi --reload uwsgi.pid
            echo "Curve reloaded."
            return
        fi
    fi
    echo "clean Curve..."
    if [ `ps -ef | fgrep curve_uwsgi | fgrep -v 'grep' | wc -l` -gt 0 ]; then
        ps -ef | fgrep curve_uwsgi | fgrep -v 'grep' | awk '{ print $2 }' | xargs kill -9
    fi
    echo "start Curve..."
    source ${G_VENV_DIR}/bin/activate
    cd ${G_API_DIR}
    ${G_VENV_DIR}/bin/curve_uwsgi uwsgi-dev.ini
    echo "Curve reloaded."
}

terminate() {
    echo "terminate Curve..."
    if [ `ps -ef | fgrep curve_uwsgi | fgrep -v 'grep' | wc -l` -gt 0 ]; then
        ps -ef | fgrep curve_uwsgi | fgrep -v 'grep' | awk '{ print $2 }' | xargs kill -9
        echo "Curve terminated."
    fi
    echo "Curve is not running."
}

case "${1}" in
start)
    version
    start
    ;;
start-dev)
    version
    start-dev
    ;;
stop)
    stop
    ;;
reload)
    version
    reload
    ;;
reload-dev)
    version
    reload-dev
    ;;
terminate)
    terminate
    ;;
help)
    help
    ;;
version)
    version
    ;;
*)
    help
    ;;
esac

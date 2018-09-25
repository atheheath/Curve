#!/bin/bash
readonly G_ROOT_DIR=`pwd`
cd ${G_ROOT_DIR}/web/build
python -m SimpleHTTPServer 8080 

#!/bin/bash

cd "$(dirname "$0")"

./deploy-backend.sh start
./deploy-frontend.sh -D 

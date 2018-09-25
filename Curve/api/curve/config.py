# -*- coding: utf-8 -*-
"""
    Curve
    ~~~~
    configure file

    :copyright: (c) 2017-2018 by Baidu, Inc.
    :license: Apache, see LICENSE for more details.
"""
import logging
import os

file_path = os.path.abspath(os.path.dirname(__file__))

STATIC_SERVER = 'http://localhost:8081'
API_SERVER = 'http://localhost:8081'
STATIC_FOLDER = 'api-doc'
STATIC_PATH = os.path.join(file_path, STATIC_FOLDER)
INDEX_PAGE = '/' + STATIC_FOLDER + '/index.html'
DEFAULT_HOST = '0.0.0.0'
DEFAULT_PORT = 8081

SAMPLE_PIXELS = 1366

DB_URL = 'sqlite:///' + os.path.join(file_path, 'curve.db')

LOG_PATH = os.path.abspath(os.path.join(file_path, os.path.pardir, 'log', 'curve'))
LOG_LEVEL = logging.INFO

OAUTH_DIR = os.path.join(file_path, 'auth')

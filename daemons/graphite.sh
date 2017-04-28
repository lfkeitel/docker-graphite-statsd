#!/bin/bash

#cd /usr/local/src/graphite-web
#/usr/bin/python /opt/graphite/webapp/graphite/manage.py runfcgi daemonize=false host=127.0.0.1 port=8080
gunicorn -w2 graphite_api.app:app -b 127.0.0.1:8080

#!/bin/bash
cd /opt/flaskapp
nohup /usr/bin/python3 app.py > /opt/flaskapp/app.log 2>&1 &

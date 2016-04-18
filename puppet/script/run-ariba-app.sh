#!/bin/bash

if [ -d "/home/ariba/pws_sources" ];then
    cd /home/ariba/pws_sources && git pull
    cd /home/ariba/pws_sources && ant amazon
else
    git clone git@bitbucket.org:fhenri/pws.source.git /home/ariba/pws_sources
    cd /home/ariba/pws_sources && git checkout aws_dev
fi


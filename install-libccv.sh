#!/bin/bash
version=0.1.1
set -ex
wget http://void.cc/libccv-$version.tar.gz
tar -xvzf libccv-$version.tar.gz -C /usr/local/lib

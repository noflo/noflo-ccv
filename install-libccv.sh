#!/bin/bash
version=0.1.1
set -ex
wget https://s3-us-west-2.amazonaws.com/cdn.thegrid.io/caliper/libvips/libccv-$version.tar.gz
tar -xzf libccv-$version.tar.gz -C /usr/local/lib

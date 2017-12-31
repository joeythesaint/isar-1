#!/bin/sh
#
# Script for Jenkins build
#
# Alexander Smirnov <asmirnov@ilbers.de>
# Copyright (c) 2016-2017 ilbers GmbH

ES_OK=0
ES_SYNTAX=1

# Export $PATH to use 'parted' tool
export PATH=$PATH:/sbin

# Get parameters from the command line
# TODO: Unify
case $# in
1)
    build_dir="$1"
    ;;
2)
    WORKSPACE="$1"
    GIT_COMMIT="$2"
    # TODO: Don't hardcode absolute paths
    build_dir="/build/$WORKSPACE/$GIT_COMMIT"
    ;;
*)
    echo "$0: Wrong number of arguments" >&2
    echo "Usage: $0 BUILD_DIR" >&2
    exit $ES_SYNTAX
    ;;
esac

# Go to Isar root
cd $(dirname $0)/..

# Setup build folder for current revision
# TODO: Why create the dir if isar-init-build-env should do that anyway?
if [ ! -d "$build_dir" ]; then
        mkdir -p "$build_dir"
fi
. ./isar-init-build-env "$build_dir"

# Start build for all possible configurations
bitbake \
        multiconfig:qemuarm-wheezy:isar-image-base \
        multiconfig:qemuarm-jessie:isar-image-base \
        multiconfig:qemuarm-stretch:isar-image-base \
        multiconfig:qemui386-jessie:isar-image-base \
        multiconfig:qemui386-stretch:isar-image-base \
        multiconfig:qemuamd64-jessie:isar-image-base \
        multiconfig:qemuamd64-stretch:isar-image-base \
        multiconfig:rpi-jessie:isar-image-base

exit $ES_OK

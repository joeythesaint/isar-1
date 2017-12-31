#!/bin/sh
#
# This software is a part of Isar.
# Copyright (C) 2017 ilbers GmbH

exec ci_build.sh `dirname $0`/../build master

#!/bin/bash
#
# This software is a part of ISAR.
# Copyright (C) 2017 ilbers GmbH
#
# TODO
# - bash required due to $LINENO, not supported by dash 0.5.7-4+b1.

TMPDIR=tmp
TESTDIR=$TMPDIR/test
CONSOLE_OUTPUT=$TESTDIR/isar_console
PID_FILE=$TESTDIR/qemu_pid

VM_TIMEOUT=120
MATCH_STR="isar login: "

DEBUG=0

. isar_test.sh
. isar_debug.sh
. isar_qemu.sh

. ./isar-init-build-env build

es=$RC_PASS

run_test i386 jessie

exit $es

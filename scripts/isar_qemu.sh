# This software is a part of Isar.
# Copyright (C) 2017 ilbers GmbH

kill_qemu() {
    pid_file="$1"

    dbg "kill_qemu $pid_file"
    # If we have been called, start_vm has still not exited; pid file must
    # exist
    if [ ! -f "$pid_file" ]; then
	err "$PID_FILE.$svm_pid doesn't exist"
    else
	qemu_pid=`cat $pid_file`
	# QEMU must be still running, show errors, if any
	kill $qemu_pid
	dbg "kill $qemu_pid: $?"
    fi
    # Visual sanity check (may show others' processes)
    is_dbg && ps ax |grep qemu-system- |grep -v grep
}

# svm exited  outf exists  timeout passed  str matches  result      kill qemu
#     0            0             1             N/A      UNRESOLVED  yes
#     0            1             *              1       PASS        yes
#     0            1             1              0       FAIL        yes
#     1            *             *              *       UNRESOLVED  no
check_output() {
    svm_pid=$1
    outf="$2.$svm_pid"

    dbg "check_output $*"
    i=0
    while [ $i -lt $VM_TIMEOUT ]; do
	# start_vm should wait at login prompt; if it exits, something is wrong
	# with the test environment
	# kill may fail if start_vm has already exited, suppress output
	if ! kill -0 $svm_pid >/dev/null 2>&1; then
	    # start_vm and, consequently, QEMU has exited, not killing QEMU
	    dbg "UNRESOLVED $LINENO: svm exited 1, waited $i"
	    return $RC_UNRESOLVED
	fi
	if [ -f "$outf" ]; then
	    str=`tail -1 "$outf" |tr -d '\r'`
	    if [ "$str" = "$MATCH_STR" ]; then
		kill_qemu "$PID_FILE.$svm_pid"
		dbg "PASS $LINENO: svm exited 0, $outf exists 1, waited $i," \
		    "\"$str\" matches 1"
		return $RC_PASS
	    fi
	fi
	i=$((i+1))
	sleep 1
    done

    # If QEMU starts, the output file must exist; if it doesn't, something is
    # wrong with the test environment
    if [ ! -f "$outf" ]; then
	kill_qemu "$PID_FILE.$svm_pid"
	dbg "UNRESOLVED $LINENO: svm exited 0, $outf exists 0, waited $i"
	return $RC_UNRESOLVED
    fi
    str=`tail -1 "$outf" |tr -d '\r'`
    if [ "$str" = "$MATCH_STR" ]; then
	kill_qemu "$PID_FILE.$svm_pid"
	dbg "PASS $LINENO: svm exited 0, $outf exists 1, waited $i," \
	    "\"$str\" matches 1"
	return $RC_PASS
    fi
    kill_qemu "$PID_FILE.$svm_pid"
    dbg "FAIL $LINENO: svm exited 0, $outf exists 1, waited $i," \
	"\"$str\" matches 0"
    return $RC_FAIL
}

run_test() {
    ARCH=$1
    DISTRO=$2

    echo "-------------------------------------------------"
    echo "Testing Isar [$DISTRO] image for [$ARCH] machine:"

    # Start QEMU with Isar image
    start_vm -a $ARCH -d $DISTRO -op $CONSOLE_OUTPUT -pp $PID_FILE \
	>/dev/null 2>&1 &
    svm_pid=$!
    inf $ARCH $DISTRO: $CONSOLE_OUTPUT.$svm_pid $PID_FILE.$svm_pid

    # Check output
    check_output $svm_pid "$CONSOLE_OUTPUT"
    r=$?
    case $r in
	$RC_PASS)
	    echo "PASS" >&2
	    ;;
	$RC_FAIL)
	    [ "$es" -eq $RC_PASS ] && es=$RC_FAIL
	    echo "FAIL" >&2
	    ;;
	$RC_KFAIL)
	    [ "$es" -eq $RC_PASS ] && es=$RC_KFAIL
	    echo "KFAIL" >&2
	    ;;
	$RC_UNRESOLVED)
	    [ "$es" -eq $RC_PASS ] && es=$RC_UNRESOLVED
	    echo "UNRESOLVED" >&2
	    ;;
	*)
	    [ "$es" -eq $RC_PASS ] && es=$RC_UNRESOLVED
	    bug "$LINENO: check_output $svm_pid $CONSOLE_OUTPUT: $r"
	    ;;
    esac

    # Keep test artifacts for debugging:
    # - $CONSOLE_OUTPUT.$svm_pid
    # - $PID_FILE.$svm_pid
}

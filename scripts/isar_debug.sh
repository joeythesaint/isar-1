# This software is a part of Isar.
# Copyright (C) 2017 ilbers GmbH

is_dbg() {
    if [ "$DEBUG" -ne 0 ]; then
	return 0
    else
	return 1
    fi
}

dbg() {
    is_dbg && echo "$0: DEBUG: $*" >&2
}

inf() {
    echo "$0: INFO: $*" >&2
}

err() {
    echo "$0: ERROR: $*" >&2
}

bug() {
    echo "$0: BUG: $*" >&2
}

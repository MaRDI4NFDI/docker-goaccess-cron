#!/bin/bash

GOACCESS_ARGS=( "$@" )

# check if log.1 is specified as input file  if file does not exist, then drop from args
# assuming that current log file (e.g. access.log) and first rotated log (access.log.1)
# are specified as the first two command line arguments
if [[ "$2" == *.log.1 ]] && [[ ! -f "$2" ]]; then
    unset "GOACCESS_ARGS[1]"
fi
/bin/goaccess "${GOACCESS_ARGS[*]}"

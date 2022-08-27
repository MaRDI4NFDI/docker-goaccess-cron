#!/bin/bash

if [[ -z $GOACCESS_SCHEDULE ]]; then
    GOACCESS_SCHEDULE="$DEFAULT_SCHEDULE"
fi

# check GoAccess command line args
# this is the list given in the `command` field in docker-compose
if [[ -z $1 ]]; then
    # no command line arguments were given. default to help
    GOACCESS_ARGS="--help"
else
    GOACCESS_ARGS="$*"
fi

# create cronjob (overriding the predefined alpine cron "run-parts" maintenance pattern)
echo "${GOACCESS_SCHEDULE} /goaccess-wrapper.sh ${GOACCESS_ARGS} >>/var/log/cron.log 2>&1" >/var/spool/cron/crontabs/root
echo "" >> /var/spool/cron/crontabs/root

crond
tail -f /var/log/cron.log

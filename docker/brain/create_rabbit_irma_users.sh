#!/bin/bash

# for some reason, without sleep this script gets stuck instead of failing if
# rabbit is not already running...
sleep 5

function exit_error {
    # prevent supervisord from restarting this script too quickly
    sleep 1
    # rabbitmq has not started yet, this script will get restarted by supervisord
    exit 1
}

# create vhosts
if ! (rabbitmqctl -n rabbit@irma list_vhosts|grep -q mqbrain)
then
    rabbitmqctl -n rabbit@irma add_vhost mqbrain || exit_error
fi
if ! (rabbitmqctl -n rabbit@irma list_vhosts|grep -q mqfrontend)
then
    rabbitmqctl -n rabbit@irma add_vhost mqfrontend || exit_error
fi
if ! (rabbitmqctl -n rabbit@irma list_vhosts|grep -q mqprobe)
then
    rabbitmqctl -n rabbit@irma add_vhost mqprobe || exit_error
fi

# create users
if ! (rabbitmqctl -n rabbit@irma list_users|grep -q brain)
then
    rabbitmqctl -n rabbit@irma add_user brain brain || exit_error
    rabbitmqctl set_permissions -p mqbrain brain '.*' '.*' '.*'
fi
if ! (rabbitmqctl -n rabbit@irma list_users|grep -q frontend)
then
    rabbitmqctl -n rabbit@irma add_user frontend frontend || exit_error
    rabbitmqctl set_permissions -p mqfrontend frontend '.*' '.*' '.*'
fi
if ! (rabbitmqctl -n rabbit@irma list_users|grep -q probe)
then
    rabbitmqctl -n rabbit@irma add_user probe probe || exit_error
    rabbitmqctl set_permissions -p mqprobe probe '.*' '.*' '.*'
fi

exit 0


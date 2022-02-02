#!/usr/bin/env bash

case "$USER" in

  treebox )
    ;;

  * ) $LOG error :env-user "Unknown user" "$USER"
    ;;

esac

#

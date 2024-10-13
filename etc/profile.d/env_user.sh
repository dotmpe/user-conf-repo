#!/usr/bin/env bash

case "$USER" in

  # This is boilerplate to add per-user shell config env & cmds
  * ) $LOG error :env-user "Unknown user" "$USER"
    ;;

esac
#

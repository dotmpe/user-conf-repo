#!/usr/bin/env bash

case "$USER" in

  # This is boilerplate to add per-user shell config env & cmds
  * )
      ! ${UC_ENV_USER:-true} || # TODO: print info about setting, fail modes?
        $LOG error :env-user "Unknown user" "$USER"
    ;;

esac
#

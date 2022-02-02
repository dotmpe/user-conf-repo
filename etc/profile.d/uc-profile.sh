test "${UC_PROFILE_LOADED-}" = "0" || {

  UC_PROFILE_LOADED=1 # Loading...

  ## Shell env defaults
  test -d "/usr/lib/user-conf" && true "${U_C:="/usr/lib/user-conf"}"
  test -d "/usr/local/lib/user-conf" && true "${U_C:="/usr/local/lib/user-conf"}"
  test -d "$HOME/.local/lib/user-conf" && true "${U_C:="$HOME/.local/lib/user-conf"}"

  true "${UC_LIB_PATH:="$U_C/script"}"

  # Dist version for this script
  true "${UC_PROFILE_DIST:="$U_C/etc/profile.d/uc-profile.sh"}"

  # The preferred installed location for this script
  true "${UC_PROFILE_SELF:="/etc/profile.d/uc-profile.sh"}"

  # User configuration runtime dir
  true "${TMPDIR:="/tmp"}"
  true "${UC_RT_DIR:="${XDG_DATA_HOME:-"$TMPDIR"}"}"

  # User configuration home dir
  true "${CONF:="${XDG_CONFIG_HOME:-"$HOME/.config"}"}"

  # Current user-conf repo location
  true "${UCONF:="$HOME/.conf"}"

  # Current default location to get profile parts
  true "${UC_PROFILE_D:="$HOME/.local/etc/profile.d"}"

  # Current default location for table specifying profile parts to load
  true "${UC_TAB:="$HOME/.local/etc/profile.tab"}"

  # XXX: subdirs of UCONF that go onto PATH later and have scripts or libs
  true "${DEFAULT_UC_PATHS:="script/box/bin:path/\$uname:path/Generic:script/\$uname:script/Generic"}"

  # XXX: need a few more bits from UCONF. drop old debug.sh
  #true "${USER_CONF_DEBUG:=x}"
  true "${UC_USER_EXPORT:="UCONF"}"

  #true "${UC_FAIL:-}"
  #true "${UC_FAILLOG:-}"
  #true "${UC_DIAG:-}"
  #true "${UC_QUIET:=1}"
  #UC_LOG_EXITS:-0
  #UC_PAUSE_ERR:-0

  true "${UC_VAR_PDNG:=}"

  true "${E_UC_PENDING:=199}"

  # uc-profile defaults for syslog-uc.lib are more strict
  true "${UC_LOG_LEVEL:=4}" # stderr: Warnings and above
  true "${UC_SYSLOG_LEVEL:=2}" # syslog: Alert and above

  # XXX: Asides from calling $LOG/$uc_log directly, the stdlog wrapper and
  # its severity-aliases can be used.

  # Stdlog offers an interface more geared to be used in a script by providing
  # function 'aliases' for each severity with a simple argument interface of
  # message and status-code. Together with STDLOG_UC_EXITS these may provide a
  # more informative way of stopping the program, like for failing argument
  # parsiong, in case of signals or in other exception cases. Like
  # UC_{SYS,}LOG_LEVEL it sets the lowest event level at which it will
  # 'trigger'. Except that exit levels range 0-255 and
  true "${STDLOG_UC_EXITS:=3}"

  # Set the maximum (or numerically lowest) severity level that will be output
  # (by filtering stderr)
  # 0 means stay quiet always
  true "${STDLOG_UC_LEVEL:=7}"

  # Set filters for stdlog-us.lib based on wether it act or not
  test $STDLOG_UC_LEVEL -eq -1 -o $STDLOG_UC_LEVEL -eq 7 && {
    test $STDLOG_UC_LEVEL -eq 7 &&
      true "${UC_PROFILE_LOG_FILTERS:="colorize"}" ||
      true "${UC_PROFILE_LOG_FILTERS:=""}"
  } || {
    # To enable STDLOG_UC_LEVEL and STDLOG_UC_ANSI:
    true "${UC_PROFILE_LOG_FILTERS:="severity colorize"}"
  }


  # Dir to record env-keys snapshots:SD-Shell-Dir
  true "${SD_SHELL_DIR:="$HOME/.statusdir/shell"}"

  ${UC_LOG_SELF:="$UC_PROFILE_SELF"}

  # Inclue log-routines and -entrypoint
  . "${U_C}/tools/sh/log.sh"

  # Set Id for shell session. This should be run first thing,
  # when next to no profile whatsoever has been loaded.
  uc_profile_init() # ~
  {
    uc_profile_load_lib || return

    argv_uc__argc :init $# eq 1 || return

    set -- $(hostname -s) $USER $(basename -- "$SHELL") $$ "$1"
    set -- $(printf '%s:' "$@")
    export UC_SH_ID="${1:0:-1}"

    # Comply with dynamic init of non-interactive shell, but be more cautious
    test -z "${PS1-}" && {
      # Don't try to exit in the middle of a script
      UC_LOG_EXITS=-1
    } || {

      # Some RC stuff
      test -z "${BASH}" || {
        #set -h # Remember the location of commands as they are looked up. (same as hashall)
        #set -E # If set, the ERR trap is inherited by shell functions.

        set -u # Treat unset variables as an error when substituting. (same as nounset)
        set -o pipefail #
      }
    }

    uc_log_init && {
      $uc_log "info" ":init" "U-c profile init has started dynamic shell setup"
      # XXX: here or in log-init. Also, remember empty setting etc.
      : "${LOG:=uc_log}"

    } || {
      # Something's already wrong, see if log works or fail Uc-profile init completely.
      LOG="${UC_PROFILE_SELF}"
      $LOG "warn" ":init" "U-c profile init has failed dynamic setup" || {
        export UC_FAIL=1
      }
    }

    # Idem.
    #test -z "${PS1-}" && {
    #}
    # XXX: not sure if there's anything beyond log here
    test "0" = "${UC_FAIL:-0}" || return

    $uc_log "info" ":init" "U-c profile init proceeding"

    # Load @Env context
    #source "$UC_LIB_PATH/context/ctx-env.lib.sh"
    #ctx__env__init
    #CTX="@Env "
    # Setup for shell env tracking
    #SD_PREF="$(ctx__env__key $UC_PROFILE_TP)"
    #uc_profile__record_env_keys -0

    UC_PROFILE_INIT=1
  }

  # Finalize init for shell session
  uc_profile_start () # ~
  {
    argv_uc__argc :start $# || return

    # Be nice and switch logger back to exec script
    export LOG="${UC_PROFILE_SELF}"

    # XXX: cleanup
    #env_initialized
    #verbosity=5 rtype=shell statusdir load

    # Hook profile-cleanup into exit trap for non-login shells
    #case "$-" in
    #  *l* ) ;;
    #  * )
    local sh
    test -n "${BASH-}" && sh=BASH || sh=SH
    trap uc_profile_cleanup_$sh exit
    #esac

    # Turn off NO-UNDEFINED again as most autocompletion scripts don't like it
    set +u

    $uc_log "notice" ":start" "Session ready" "$UC_PROFILE_TP"
  }

  # Add parts to shell session
  uc_profile_load () # ~ NAME [TAG]
  {
    argv_uc__argc :load $# gt || return

    local exists=1 name="$1" envvar ret
    fnmatch "\**" "$1" && {
        exists=0; name="${1:1}"
    }
    shift
    envvar=UC_PROFILE_D_${name^^}

    # Skip if already loaded
    test -z "${!envvar-}" || return 0

    # During loading UC_PROFILE_D_<name>=1, and at the end it is set to the source return status.
    # However the script itself....
    eval $envvar=-1

    # During source of the env file, `uc_profile_load{,_path,_tag}` can be referred to.

    local uc_profile_load="$1" uc_profile_tag="${2:-}"

    local uc_profile_load_path=$( for profile_d in ${UC_PROFILE_D//:/ };
        do
            test -e "$profile_d/$name.sh" || continue
            printf '%s' "$profile_d/$name.sh"
            break
        done )

    # Bail if no such <name> profile exists
    test -e "$uc_profile_load_path" || {
      # error unless '*<name>' was specified
      test $exists -eq 0 && return -1
      $uc_log "error" ":load" "Error: no uc-source" "$name"
      return 6
    }

    uc_source "$uc_profile_load_path"
    ret=$?

    # File exists, so we have a status either way
    test "${!envvar}" != "-1" || unset $envvar

    test "0" = "${ret-}" && {
      test "${!envvar:-0}" = "0" || stat=${!envvar}
    }

    # If non-zero and not pending, set UC_PROFILE_D_<name> to status.
    # Otherwise return pending directly and unset UC_PROFILE_D_<name>
    test $ret -eq 0 || {
      test $ret -eq $E_UC_PENDING && {
        return $E_UC_PENDING
      }
    }

    eval $envvar=$ret
  }

  # End shell session
  uc_profile_cleanup ()
  {
    # TODO: keep be (name, rtpe, other params) in settings/meta.sh file
    #verbosity=5 fsd_rtype=shell statusdir.sh be del "$UC_SH_ID*" -- deinit shell
    set -- "$SD_SHELL_DIR/$UC_SH_ID"*.sh
    test $# -eq 0 || rm "$@"
    exit ${rs-}
  }

  # Exit trap handlers specific to Shell version
  uc_profile_cleanup_SH ()
  {
    local rs=$?
    test -z "$rs" -o "$rs" = "0" || {
      $uc_log "warn" ":cleanup" "Some command exited with code [$rs]"
    }
    uc_profile_cleanup
  }

  uc_profile_cleanup_BASH ()
  {
    local lc="$BASH_COMMAND" rs=$?
    test -z "$rs" -o "$rs" = "0" || {
      $uc_log "warn" ":cleanup" "Command [$lc] exited with code [$rs]"
      test "${UC_PAUSE_ERR:-0}" = 0 ||
         read -sp "Press any key... (E$rs)
" -n1
    }
    uc_profile_cleanup
  }

  # Source file (with UC-DEBUG option and updates ENV-SRC)
  uc_source () # ~ [Source-Path]
  {
    test $# -gt 0 -a -n "${1-}" || {
      $uc_log error ":source" "Expected file argument" "$1"; return 64
    }

    local r
    . "$1" || r=$?
    ENV_SRC="$ENV_SRC$1 "

    test ${r-0} -eq 0 && {
      test -z "${USER_CONF_DEBUG-}" ||
        $uc_log "debug" ":source" "Done sourcing" "$1"
    } || {
      $uc_log "error" ":source" "Error ($r) sourcing" "$1"
    }
    return ${r-}
  }

  # Same as uc-source but also take snapshot of env vars name-list
  # FIXME: relative to previous snapshot.
  uc_import () # ~ [Source-Path]
  {
    uc_source "$@" || return
    uc_profile__record_env__keys $(echo "${1//\//-}" | uc_mkid)
    # TODO: record ENV-SRC snapshot as well.
    $uc_log warn ":import" "New env loaded, keys stored" "$1"
  }

  # XXX: how to deal with env vars..
  uc_profile_default_tab_or_bail () # TAB [types...]
  {
    uc_env_init UC_PROFILE_TAB

    return 1
  }

  # Besides init/start/end this is the mayor step of UC-profile, performed
  # several times during shell init.
  uc_profile_boot () # TAB [types...]
  {
    test -n "${1-}" || -- set $UC_TAB $*
    test -s "${1-}" || {
      $uc_log "crit" ":boot" "Missing or empty profile table" "${1-}"
      return
    }

    test $# -gt 0 -a -e "${1-}" || return 64
    local tab="$1"; shift 1

    test $# -gt 0 && UC_PROFILE_TP="$*" || set -- $UC_PROFILE_TP

    local c="${UC_RT_DIR}/user-$(id -u)-profile.tab"
    test ! -e "$c" -o "$c" -ot "$tab" && {
      grep -v -e '^ *#' -e '^ *$' "$tab" >"$c"
    }

    test ! -e "$c" -o "$c" -ot "$tab" && {
      grep -v -e '^ *#' -e '^ *$' "$tab" >"$c"
    }

    local name type
    while read name type
    do
      test -n "$type" -a $# -gt 0 && {
        # Skip entry unless '$*' matches any type for entry
        local tp m=0
        for tp in $@; do fnmatch "* $tp *" " $type " && m=1 || continue; done

        test $m -eq 1 || {
          test -z "${USER_CONF_DEBUG-}" ||
            $uc_log warn ":boot<>$name" "Skipped profile.tab entry" "$type not in $*"
          continue
        }
      }

      # uc_profile_load already does the same envvar name building,
      # but we want to pick up any setting left by profile here
      fnmatch "\**" "$name" && rname=${name:1} || rname=$name
      envvar=UC_PROFILE_D_${rname^^}

      unset stat $envvar 2>&1 > /dev/null
      uc_profile_load "$name" $type || stat=$?

      # No such file, only list sourced files
      test ${!envvar:-0} -eq -1 && continue

      # Append name to list, concat error code if there is one
      names="${names:-}$name${stat:+":E"}${stat-} "

      # XXX: UC_BOOT_ABORT stops at first failing boot-item. Maybe set per-tabline
      #test -z "${stat-}" || {
      #  test $stat -eq $E_UC_PENDING || return $stat
      #}
    done <"$c"
    $uc_log notice ":boot" "Boostrapped '$*' from user's profile.tab" "${names-}"
    return
  }


  uc_user_init ()
  {
    argv_uc__argc :uc-user-init $# || return
    local key= value=
    for key in ${UC_USER_EXPORT:-}
    do
      uc_var_update "$key" || {
        $uc_log "error" "" "Missing user env" "$key"
      }
    done
  }

  uc_var_reset ()
  {
    argv_uc__argc :uc-var-reset $# eq 1 || return
    local def_key def_val
    def_key="DEFAULT_${1^^}"
    def_val="${!def_key?Cannot reset user env $1}"
    test -n "$def_val" || return
    eval "$1=\"$def_val\""
  }

  uc_var_update ()
  {
    argv_uc__argc :uc-var-update $# eq 1 || return
    uc_func var_${1^^}_update && {

      var_${1^^}_update || return
    }
    test -n "${!1-}" || uc_var_reset "$1"
  }

  uc_var_define ()
  {
    argv_uc__argc :uc-var-define $# eq 1 || return
    eval "$(cat <<EOM

var_${1^^}_update ()
{
$(cat)
}

EOM
)"
  }

  # Record env keys only; assuming thats safe, no literal dump b/c of secrets
  uc_profile__record_env__keys ()
  {
    argv_uc__argc_n :record-env:keys $# eq 1 || return

    # XXX: if statusdir was loaded....
    #env_keys > rtype=shell sd_fsdir_file $UC_SH_ID:$1

    test ! -e "$SD_SHELL_DIR/$UC_SH_ID:$1.sh" || {
      $uc_log "error" ":record-env:keys" "Keys already exist" "$1"
      return 1
    }
    env_keys > "$SD_SHELL_DIR/$UC_SH_ID:$1.sh"
  }

  uc_profile__record_env__ls ()
  {
    argv_uc__argc_n :record-env-ls $# || return
    for name in "$SD_SHELL_DIR/$UC_SH_ID"*
    do
      echo "$(ls -la "$name") $( count_lines "$name") keys"
    done
  }

  env_keys() # ~
  {
    argv_uc__argc :env-keys $# || return
    printenv | sed 's/=.*$//' | grep -v '^_$' | sort -u
  }

  uc_profile__record_env__diff_keys () # ~ FROM TO
  {
    test -n "${1-}" || set -- "$(ls "$SD_SHELL_DIR" | head -n 1)" "${2-}"
    test -n "${2-}" || set -- "$1" "$(ls "$SD_SHELL_DIR" | tail -n 1)"
    argv_uc__argc_n :env-diff-keys $# eq 2 || return

    # FIXME:
    #test -e "$1" -a -e "$2" || stderr ":record-env:keys-diff" '' 1
    #test -e "$SD_SHELL_DIR/$1" -a -e "$SD_SHELL_DIR/$2" || error "record-env:keys-diff" 1

    #$uc_log notice "" "comm -23 '$SD_SHELL_DIR/$2' '$SD_SHELL_DIR/$1'"
    comm -23 "$SD_SHELL_DIR/$2" "$SD_SHELL_DIR/$1"
  }

  uc_mkid () # ~
  {
    argv_uc__argc :env-keys $# || return
    tr -cd '[:alnum:]' | tr '[:upper:]' '[:lower:]'
  }

  UC_PROFILE_LOADED=0 # Loaded
}

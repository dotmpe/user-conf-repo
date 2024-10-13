### User-Conf profile: Shell bootstrap for user-tools

# shellcheck disable=SC1090 # Ignore non-constant source and provide no directive
test "${UC_PROFILE_LOADED-}" = "0" || {
  UC_PROFILE_LOADED=1 # Loading...

  ## Static env for uc-profile (global)
  test ! -s /etc/profile.d/_static.sh || . /etc/profile.d/_static.sh

  # Default location to get user-conf profile parts
  true "${UC_PROFILE_D:="$HOME/.local/etc/profile.d"}"

  ## Static env for uc-profile (user)
  test ! -s $UC_PROFILE_D/_static.sh || . $UC_PROFILE_D/_static.sh

  # User-Conf must be in _static.sh, or installed at one of these locations
  test -d "${U_C-}" || {
    [[ ! ${U_C-} ]] || unset U_C

    # If U-C is not configured, do a very conservative scan, some at HOME and
    # one at ${PREFIX:=/usr}
    : "${PREFIX:=/usr}"
    test -d "${HOME:?}/.local/lib/user-conf/" && true "${U_C:="$HOME/.local/lib/user-conf"}"
    # look for basher install
    test -d "${HOME:?}/.basher/cellar/packages/user-tools/user-conf/" && true "${U_C:="$HOME/.basher/cellar/packages/user-tools/user-conf"}"
    test -d "${PREFIX:?}/local/lib/user-conf/" && true "${U_C:="${PREFIX:?}/local/lib/user-conf"}"
    test -d "${PREFIX:?}/lib/user-conf/" && true "${U_C:="${PREFIX:?}/lib/user-conf"}"
    # XXX: maybe for dev, ci modes do builtin dev-mode as well
    test -d "/src/local/user-conf/current+r0.2" && true "${U_C:="/src/local/user-conf/current+r0.2"}"
    #test -d "/src/local/user-conf" && true "${U_C:="/src/local/user-conf"}"
  }

  test -d "${U_C-}" && {
    ## Restart from cache or require any working env

    # Include log-routines and -entrypoint here (to use uc-profile.sh as command
    # script handler as well)
    . "${U_C}/script/uc-profile.lib.sh" &&
    uc_profile_reboot &&
    . "${U_C}/tool/sh/log.sh"

    UC_PROFILE_LOADED=0 # Loaded
  } || {
    echo "Cannot get User-Conf installation directory <U-c:${U_C:-"(unset)"}>. Skipped loading uc-profile. " >&2
  }
}

#!/bin/sh

# Export all specific data about current OS
# For more generic info, see generic.sh

test ! -s /etc/os-release && {
  # Set some values as reported by OS.
  # They are prefixed OS_ to indicate these values are not verified in any other
  # way. See also os.sh for specific values about current OS distribution.

  : "${OS_UNAME:="$(uname -s)"}"
  : "${OS_HOST:="$(hostname --long)"}"
  [[ ${OS_HOSTNAME:+set} ]] || {
    : "$(hostname --short)"
    OS_HOSTNAME="${_,,}"
  }
  export OS_{UNAME,HOST{NAME,}}

  stderr declare -p OS_{UNAME,HOST{NAME,}}

} || {

  eval $(sed 's/^/OS_/g' /etc/os-release)
  export $(sed 's/^\([^=]*\)=.*$/OS_\1/' /etc/os-release)
}

# Id: User-conf.seed/etc/profile.d/os.sh

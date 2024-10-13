test -z "${BASH_VERSINFO-}" || {

  # prevent IO redirection from overwriting
  set -o noclobber

  # Try to save multi-commands as one history line
  shopt -s cmdhist

  # Append to the history file, don't overwrite it.
  # See also prompt-command to use history -a
  shopt -s histappend


  # ignoredups: don't add put subsequent duplicate lines in the history, and
  # ignorespace: ignore commands starting with spaces. ignoreboth is both these.
  # What I want though is no duplicates at all, called erasedups. Replace
  # duplicate entries and keep latest last.
  export HISTCONTROL=ignoreboth

  # This setting causes timestamps to be inserted before new entries.
  # NOTE: this is *NOT* the storage format but the display format of the
  # ``history`` command.
  export HISTTIMEFORMAT="%F %T "

  # check the window size after each command and, if necessary,
  # update the values of LINES and COLUMNS.
  shopt -s checkwinsize


  shopt -s cdable_vars
  shopt -s cdspell
}

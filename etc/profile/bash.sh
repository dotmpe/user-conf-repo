test -z "${BASH_VERSINFO-}" || {

  # Try to save multi-commands as one history line
  shopt -s cmdhist

  # Append to the history file, don't overwrite it.
  # See also prompt-command to use history -a
  shopt -s histappend

  shopt -s cdspell
}

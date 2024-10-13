#!/bin/sh

# XXX: some user space space thing: the editr

# Editors in order of preference
for EDITOR_ in vim vi nano ed
do
  if test -x "$(command -v $EDITOR_)"
  then
    export EDITOR=$EDITOR_
    break
  fi
done
unset EDITOR_

# Id: User-conf.seed/etc/profile.d/generic.sh

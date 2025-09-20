#!/usr/bin/bash

PKG_DIR="/home/repo/rhel810_local_rpms"
LOG="/home/update_check.log"

{
  dnf --disablerepo='*' --setopt=tsflags=test -y localinstall "${PKG_DIR}"/*.rpm
  RC=$?

  echo "--- dnf localinstall(test) end rc=${RC} ---"
  exit $RC
} >"$LOG" 2>&1

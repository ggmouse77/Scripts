#!/bin/bash

PKG_DIR="/user/svrauto/SA/OS/2025PM/rhel810_local_rpms"
LOG="/home/update_check.log"

{
  dnf --disablerepo='*' --setopt=tsflags=test -y localinstall "${PKG_DIR}"/*.rpm
  RC=$?

  echo "--- dnf localinstall(test) end rc=${RC} ---"
  exit $RC
} >"$LOG" 2>&1

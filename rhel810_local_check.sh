#!/bin/bash

PKG_DIR="/root/repo"
LOG="/root/update_check.log"

dnf --disablerepo='*' localinstall ${PKG_DIR}/*.rpm --assumeno > "$LOG" 2>&1

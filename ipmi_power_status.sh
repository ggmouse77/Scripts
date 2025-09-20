#!/usr/bin/bash
LIST="hosts.txt"
ID="admin"      
PW="password"
# =====================

while IFS= read -r HOST || [[ -n "$HOST" ]]; do
  [[ -z "$HOST" || "$HOST" =~ ^# ]] && continue
  MGMT="${HOST}-m"

  if fping -q -c1 -t1000 "$MGMT" 2>/dev/null; then
    if OUT=$(ipmitool -I lanplus -H "$MGMT" -U "$ID" -P "$PW" chassis power status 2>/dev/null); then
      echo "$HOST, $OUT"                  
    else
      echo "$HOST, IPMI Over Lan Connect Fail"
    fi
  else
    echo "$HOST, Ping Unreachable"
  fi
done < "$LIST"

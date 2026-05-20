#!/usr/bin/env bash
# Lab 4.3 trigger — SMB brute-force from Kali to generate ≥6 EID 4625 events against
# the same TargetUserName from the same WorkstationName, within 10 minutes. The Sigma
# correlation rule (#2) groups by TargetUserName + WorkstationName and fires at > 5.
TARGET="${1:-10.16.1.110}"
USER="${2:-administrator}"
PASSWORDS=("Wrong1!" "Wrong2!" "Wrong3!" "Wrong4!" "Wrong5!" "Wrong6!" "Wrong7!")
echo "[*] Brute force against $TARGET as $USER"
for p in "${PASSWORDS[@]}"; do
    echo "[*] Trying $p"
    smbclient -L "$TARGET" -U "${USER}%${p}" -t 5 >/dev/null 2>&1
    echo "  rc=$?"
    sleep 1
done
echo "[*] Done at $(date +%T)"

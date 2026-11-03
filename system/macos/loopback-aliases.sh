#!/bin/sh

# Add each address independently so a failure does not prevent later additions.
if ! interfaces=$(/sbin/ifconfig lo0); then
    echo "Failed to read lo0 addresses" >&2
    exit 1
fi

existing=$(printf '%s\n' "$interfaces" | /usr/bin/awk '$1 == "inet" { print $2 }')
status=0
i=1
while [ "$i" -le 254 ]; do
    address="127.17.17.$i"
    if ! printf '%s\n' "$existing" | /usr/bin/grep -Fqx "$address"; then
        if ! /sbin/ifconfig lo0 inet "$address" netmask 255.255.255.255 alias; then
            echo "Failed to add $address to lo0" >&2
            status=1
        fi
    fi
    i=$((i + 1))
done

exit "$status"

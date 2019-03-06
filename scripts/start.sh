#!/bin/bash

if [ ! -d /opt/ldap/bin ]; then
  echo "unpacking datafile"
  tar -C /opt -xvzf /opt/ldap.tar.gz
  /opt/scripts/create.sh
fi

/opt/ldap/libexec/slapd -d 1 -F /opt/ldap/etc/openldap
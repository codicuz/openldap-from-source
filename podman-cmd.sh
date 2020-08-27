#!/bin/bash

DINAME="localhost/openldap:2.4.51"
DCNAME="c-ldap"
HOSTNAME="ldap.codicus.ru"

NO_ARGS=0
E_OPTERR=65

if [ $# -eq "$NO_ARGS" ]
then
  printf "No arguments. Must have arguments.\n"
  printf "Usage: $0 {-build|-rmi|-none|-rmfa|-run|-restart|-rmf|-exec|-exec0|-logsf}\n"
  printf " $0 -run - create and start container $DCNAME\n" 
  printf " $0 -restart - restart container $DCNAME\n"
  printf " $0 -rmf - remove container $DCNAME (podman rm -f $DCNAME)\n"
  printf " $0 -rmfa - remove all container (podman rm -f \$(dokcer ps -a -q)\n"
  printf " $0 -exec - run a command in a running container $DCNAME (podman exec -it $DCNAME /bin/bash)\n"
  printf " $0 -exec0 - run a command in a running container $DCNAME from user with uid 0 (podman exec -it -u 0 $DCNAME /bin/bash)\n"
  printf " $0 -logsf - fetch the logs of a container $DCNAME with follow option (podman logs -f $DCNAME)\n"
  printf " $0 -build - build image $DINAME\n"
  printf " $0 -rmi - remove image $DINAME\n"
  printf " $0 -none - remove image where repository NONE\n"
  exit $E_OPTERR
fi

while :; do
	case "$1" in
	-build)
	  podman build -t $DINAME .
	 ;;
	-rmi)
	  podman rmi $DINAME
	 ;;
	-none)
	  podman rmi $(podman images -f "dangling=true" -q)
	 ;;
	-rmfa)
	  podman rm -f $(podman ps -a -q)
	 ;;
	-run)
	  podman run -td \
	  --hostname $HOSTNAME \
	  --publish 389:389  \
	  --name $DCNAME \
	  --volume $PWD/volumes/ldap:/opt/ldap \
	  --volume $PWD/ldifs:/opt/ldifs \
	  $DINAME
	 ;;
	-import)
	  podman exec -it $DCNAME /opt/ldap/sbin/slapadd -n 0 -F /opt/ldap/etc/openldap -l /opt/ldifs/slapd.ldif
	 ;;
	-import2)
	  podman exec -it $DCNAME /opt/ldap/bin/ldapadd -x -D "cn=admin,dc=example,dc=lan" -W -f /opt/ldifs/example.ldif
	 ;;
	-restart)
	  podman restart $DCNAME
	 ;;
	-rmf)
	  podman rm -f $DCNAME
	 ;;
	-exec)
	  podman exec -it $DCNAME /bin/bash
	 ;;
	-exec0)
	  podman exec -it -u 0 $DCNAME /bin/bash
	 ;;
	-logsf)
	  podman logs -f $DCNAME
	 ;;
	--)
	  shift
	 ;;
	?* | -?*)
	  printf 'WARNING: unknown argument (ignored): %s\n' "$1" >&2
	 ;;
	*)
	  break
	esac
	shift
done

exit 0
#!/bin/bash

DINAME="centos-ldap:latest"
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
  printf " $0 -rmf - remove container $DCNAME (docker rm -f $DCNAME)\n"
  printf " $0 -rmfa - remove all container (docker rm -f \$(dokcer ps -a -q)\n"
  printf " $0 -exec - run a command in a running container $DCNAME (docker exec -it $DCNAME /bin/bash)\n"
  printf " $0 -exec0 - run a command in a running container $DCNAME from user with uid 0 (docker exec -it -u 0 $DCNAME /bin/bash)\n"
  printf " $0 -logsf - fetch the logs of a container $DCNAME with follow option (docker logs -f $DCNAME)\n"
  printf " $0 -build - build image $DINAME\n"
  printf " $0 -rmi - remove image $DINAME\n"
  printf " $0 -none - remove image where repository NONE\n"
  exit $E_OPTERR
fi

while :; do
	case "$1" in
	-build)
	  docker build -t $DINAME .
	 ;;
	-rmi)
	  docker rmi $DINAME
	 ;;
	-none)
	  docker rmi $(docker images -f "dangling=true" -q)
	 ;;
	-rmfa)
	  docker rm -f $(docker ps -a -q)
	 ;;
	-run)
	  docker run -td \
	  --hostname $HOSTNAME \
	  --publish 389:389  \
	  --name $DCNAME \
	  --volume $PWD/volumes/ldap:/opt/ldap \
	  $DINAME
	 ;;
	-import)
	  docker exec -it $DCNAME /opt/ldap/sbin/slapadd -n 0 -F /opt/ldap/etc/openldap -l /opt/ldifs/slapd.ldif
	 ;;
	-import2)
	  docker exec -it $DCNAME /opt/ldap/bin/ldapadd -x -D "cn=admin,dc=example,dc=lan" -W -f /opt/ldifs/example.ldif
	 ;;
	-restart)
	  docker restart $DCNAME
	 ;;
	-rmf)
	  docker rm -f $DCNAME
	 ;;
	-exec)
	  docker exec -it $DCNAME /bin/bash
	 ;;
	-exec0)
	  docker exec -it -u 0 $DCNAME /bin/bash
	 ;;
	-logsf)
	  docker logs -f $DCNAME
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
FROM centos:7 as base

RUN yum -y update \
  && yum -y install iproute mc \
  && yum clean all \
  && rm -rfv /var/cache/yum

FROM base as builder

ARG LDAP_ARCH="openldap-2.4.51.tgz"
ARG LDAP_ARCH_PATH="/opt/openldap.tgz"
ARG LDAP_URL="http://mirror.eu.oneandone.net/software/openldap/openldap-release/$LDAP_ARCH"

RUN yum -y install gcc epel-release libdb-devel make groff groff-base \
  && curl -L $LDAP_URL -o $LDAP_ARCH_PATH \
  && tar -C /opt -xvzf $LDAP_ARCH_PATH

WORKDIR /opt/openldap-2.4.51

RUN ./configure --prefix=/opt/ldap \
  && make depend \
  && make \
  && make install \
  && tar -C /opt -cvzf /opt/ldap.tar.gz ldap

FROM base

LABEL maintainer="Codicus"

ADD conf/custom.sh /etc/profile.d
ADD scripts /opt/scripts
ADD ldifs /opt/ldifs

RUN chmod -R +x /opt/scripts

COPY --from=builder /opt/ldap.tar.gz /opt/ldap.tar.gz

ENTRYPOINT ["/opt/scripts/start.sh"]
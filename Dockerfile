#from 2016 to 2022
FROM alpine:3.4
RUN apk add --no-cache ca-certificates

ENV PYTHON_VERSION=2.7.14
ENV PYTHON_PIP_VERSION=9.0.1
# ENV GPG_KEY=B42F6819007F00F88E364FD4036A9C25BF357DD4
# ENV KEYSERVER=pgp.mit.edu

RUN set -ex  && apk add --no-cache  git  gnupg   openssl   tar   xz   wget && wget -O python.tar.xz "https://www.python.org/ftp/python/${PYTHON_VERSION%%[a-z]*}/Python-$PYTHON_VERSION.tar.xz"  && wget -O python.tar.xz.asc "https://www.python.org/ftp/python/${PYTHON_VERSION%%[a-z]*}/Python-$PYTHON_VERSION.tar.xz.asc" && mkdir -p /usr/src/python  && tar -xJC /usr/src/python --strip-components=1 -f python.tar.xz  && rm python.tar.xz && apk add --no-cache --virtual .build-deps    bzip2-dev   coreutils   dpkg-dev dpkg   gcc   gdbm-dev   libc-dev   linux-headers   make   ncurses-dev   openssl   openssl-dev   pax-utils   readline-dev   sqlite-dev   tcl-dev   tk   tk-dev   zlib-dev  && cd /usr/src/python  && gnuArch="$(dpkg-architecture --query DEB_BUILD_GNU_TYPE)"  && ./configure   --build="$gnuArch"   --enable-shared   --enable-unicode=ucs4 && make -j "$(nproc)"  && make install  && runDeps="$(   scanelf --needed --nobanner --recursive /usr/local    | awk '{ gsub(/,/, "\nso:", $2); print "so:" $2 }'    | sort -u    | xargs -r apk info --installed    | sort -u  )"  && apk add $runDeps  

RUN set -ex; apk add --no-cache python-dev g++; wget -O get-pip.py 'https://bootstrap.pypa.io/pip/2.7/get-pip.py'; python get-pip.py --disable-pip-version-check   --no-cache-dir "pip==$PYTHON_PIP_VERSION"; pip --version;

WORKDIR /opt/SwiperProxy/swiperproxy/

RUN git clone https://github.com/simmessa/swiperproxy.git && cd swiperproxy; ls; cd include/streamhtmlparser; ./configure && make && make install
RUN pip install ipy==0.83
RUN mkdir -p /var/log/swiperproxy/
COPY . /opt/SwiperProxy/swiperproxy
COPY entrypoint.sh /entrypoint.sh
RUN chmod a+x /entrypoint.sh

ENTRYPOINT ["sh", "/entrypoint.sh", "/opt/SwiperProxy/swiperproxy/Proxy.py", "-c", "/opt/SwiperProxy/swiperproxy/proxy.conf"]

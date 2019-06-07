FROM centos:centos7
LABEL authors="bublikoff@gmail.com"

RUN yum -y install \
kernel-headers gcc gcc-c++ cpp bzip2 patch \
ncurses ncurses-devel libxml2 libxml2-devel \
sqlite sqlite-devel openssl-devel newt-devel \
kernel-devel libuuid-devel net-snmp-devel unixODBC \
unixODBC-devel mysql-connector-odbc libtool-ltdl \
libtool-ltdl-devel xinetd tar make git wget file \
postgresql-devel postgresql-odbc libuuid-devel \
lua lua-devel unzip readline-devel \
mysql-devel curl-devel libedit-devel \
libedit-devel epel-release libffi-devel svn \
    && yum install -y lame luarocks \
    && yum -y clean all \
    && rm -rf /var/cache/yum \
    && mkdir -p /usr/src/asterisk \
    && cd /usr/src \
    && wget http://downloads.asterisk.org/pub/telephony/asterisk/asterisk-16-current.tar.gz \
    && tar -xzvf /usr/src/asterisk-16-current.tar.gz --strip-components=1 -C /usr/src/asterisk \
    && mv /etc/localtime /etc/localtime.bak \
    && ln -s /usr/share/zoneinfo/Europe/Moscow /etc/localtime \
    && cd /usr/src/asterisk/contrib/scripts \
	&& ./install_prereq install-unpackaged \
	&& cd /usr/src/asterisk \
    && ./configure CFLAGS='-march=core2 -msse4.2 -msse4.1 -mpopcnt -O2 -pipe' --libdir=/usr/lib64 --with-jansson-bundled --with-pjproject-bundled \
    && make menuselect.makeopts \
    && menuselect/menuselect \
        --disable BUILD_NATIVE \
        --enable res_config_mysql \
        --enable app_mysql \
        --enable CORE-SOUNDS-EN-WAV \
        --enable CORE-SOUNDS-EN-ULAW \
		--enable EXTRA-SOUNDS-EN-WAV \
        --enable EXTRA-SOUNDS-EN-ULAW \
        --enable CORE-SOUNDS-RU-WAV \
        --enable CORE-SOUNDS-RU-ULAW \
        --enable G711_NEW_ALGORITHM \
        --enable G711_REDUCED_BRANCHING \
		--enable codec_g726 \
		--enable format_g726 \
        --enable chan_sip \
        --enable res_snmp \
		--enable res_srtp \
    menuselect.makeopts \
    && make && make install && make samples \
    && cd /usr/src \
    && git clone https://github.com/keplerproject/luasql.git \
    && cd /usr/src/luasql \
    && /usr/bin/sed -i 's/5.2/5.1/g' config \
    && /usr/bin/sed -i 's/\/lib\/lua/\/lib64\/lua/g' config \
    && /usr/bin/sed -i 's/\/usr\/lib/\/usr\/lib64/g' config \
    && /usr/bin/sed -i 's/lib64\ \-lmysqlclient/lib64\/mysql\ \-lmysqlclient/g' config \
    && make mysql \
    && make install \
    && /bin/luarocks install lua-resty-socket \
    && /bin/luarocks install luasocket \
    && /bin/luarocks install luasec \
    && /bin/luarocks install sha1 \
    && /bin/luarocks install lua-MessagePack \
    && /bin/luarocks install luasql-postgres \
    && /bin/luarocks install luacrypto \
    && /bin/luarocks install lunit \
    && /bin/luarocks install lua-cjson \
    && /bin/luarocks install luaposix \
    && /bin/luarocks install lbase64 \
    && /bin/luarocks install md5 \
    && /bin/luarocks install xml \
    && /bin/luarocks install inspect \
    && /bin/luarocks install luajson \
    && /bin/luarocks install lua-curl \
    && /bin/luarocks install lua-requests \
    && cd /usr/src \
    && git clone https://github.com/cloudflare/raven-lua \
    && cp -r /usr/src/raven-lua/raven /usr/share/lua/5.1/ \
    && wget http://asterisk.hosting.lv/bin/codec_g729-ast160-gcc4-glibc-x86_64-pentium4.so -O /usr/lib64/asterisk/modules/g729.so \
    && rm -rf /usr/src \
    && yum remove -y --setopt=tsflags=noscripts *devel git gcc gcc-c++ cpp iproute iptables wget \
    && yum -y autoremove && yum -y install libedit && yum -y clean all \
    && rm -rf /var/cache/* \
    && rm -rf /usr/src/*
#MAX FILES UP
RUN sed -i 's/'\#\ MAXFILES\=\32768'/'MAXFILES\=\99989'/g' /usr/sbin/safe_asterisk && sed -i 's/TTY=9/TTY=/g' /usr/sbin/safe_asterisk
CMD asterisk -f

FROM --platform=linux/amd64 centos:7
EXPOSE 80 443 3000
RUN mkdir /app
WORKDIR /app

RUN yum install -y yum-utils
RUN yum-config-manager --add-repo https://openresty.org/package/centos/openresty.repo && yum install -y openresty openresty-resty openresty-opm
RUN yum install -y vim

ADD stats.lua       /app/stats.lua
ADD protect.lua     /app/protect.lua
ADD ping.lua        /app/ping.lua
ADD record.lua      /app/record.lua
ADD cert.key        /app/cert.key
ADD cert.pem        /app/cert.pem
ADD env.conf        /app/env.conf
ADD nginx.conf      /app/nginx.conf

CMD ["openresty", "-c", "/app/nginx.conf"]

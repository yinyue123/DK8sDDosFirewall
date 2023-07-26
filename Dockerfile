FROM openresty/openresty:stretch as builder
RUN mkdir /app
WORKDIR /app

ADD stats.lua   /app
ADD protect.lua   /app

RUN /usr/local/openresty/luajit/bin/luajit -b /app/stats.lua /app/stats.ljbc
RUN /usr/local/openresty/luajit/bin/luajit -b /app/protect.lua /app/protect.ljbc

FROM --platform=linux/amd64 openresty/openresty:stretch
EXPOSE 80 443

RUN mkdir /app
WORKDIR /app
COPY --from=builder /app/stats.ljbc  /app/
COPY --from=builder /app/protect.ljbc  /app/
ADD nginx.conf      /app/nginx.conf

CMD ["openresty", "-c", "/app/nginx.conf"]

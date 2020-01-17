FROM alpine:3.10 as builder

RUN apk add --no-cache \
    curl \
    git

ENV VERSION 0.62.2 
ENV GIT "https://github.com/Jarzamendia/prf.git"

RUN mkdir -p /usr/local/src \
    && cd /usr/local/src \
    && curl -L https://github.com/gohugoio/hugo/releases/download/v${VERSION}/hugo_${VERSION}_linux-64bit.tar.gz | tar -xz \
    && mv hugo /usr/local/bin/hugo \
    && curl -L https://bin.equinox.io/c/dhgbqpS8Bvy/minify-stable-linux-amd64.tgz | tar -xz \
    && mv minify /usr/local/bin/ \
    && addgroup -Sg 1000 hugo \
    && adduser -SG hugo -u 1000 -h /src hugo

WORKDIR /src

RUN git clone ${GIT} .

RUN hugo

FROM nginx:1.17.7-alpine

COPY default.conf /etc/nginx/conf.d/default.conf

COPY --from=builder /src/public /usr/share/nginx/html

ARG BUILD_DATE
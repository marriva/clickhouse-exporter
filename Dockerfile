FROM golang:1.18-buster as builder

WORKDIR /src

COPY . .

RUN go get -v github.com/prometheus/promu \
    && promu build -v --prefix build


FROM debian:buster-slim
LABEL maintainer="Vasily Maryutenkov <vasily.maryutenkov@flant.com>"

RUN DEBIAN_FRONTEND=noninteractive; apt-get update \
    && apt-get install -qy --no-install-recommends \
        ca-certificates \
        curl

COPY --from=builder /src/build/clickhouse-exporter /clickhouse-exporter

EXPOSE 8888/tcp

CMD [ "/clickhouse-exporter" ]
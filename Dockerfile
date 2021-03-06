FROM golang:1.18-buster as builder

WORKDIR /src/clickhouse-exporter

ARG CHOP_VERSION=0.18.5
ARG PROMU_VERSION=0.13.0

COPY . .

RUN git clone --single-branch --branch $CHOP_VERSION https://github.com/altinity/clickhouse-operator ../clickhouse-operator \
    && go install -v github.com/prometheus/promu@v$PROMU_VERSION \
    && /go/bin/promu build -v --prefix build


FROM debian:buster-slim
LABEL maintainer="Vasily Maryutenkov <vasily.maryutenkov@flant.com>"

RUN DEBIAN_FRONTEND=noninteractive; apt-get update \
    && apt-get install -qy --no-install-recommends \
        ca-certificates \
        curl

COPY --from=builder /src/clickhouse-exporter/build/clickhouse-exporter /clickhouse-exporter

EXPOSE 8888/tcp

CMD [ "/clickhouse-exporter" ]

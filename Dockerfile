ARG GO
FROM golang:${GO}-bookworm AS builder
ARG VERSION
WORKDIR /src
COPY src .
RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 \
    go build -trimpath -ldflags="-s -w -X main.GitCommit=${VERSION}" -o /out/tonutils-storage-provider ./cmd

FROM debian:bookworm-slim
RUN apt-get update && \
    apt-get install -y --no-install-recommends ca-certificates && \
    rm -rf /var/lib/apt/lists/*
COPY --from=builder /out/tonutils-storage-provider /usr/local/bin/tonutils-storage-provider
WORKDIR /data
EXPOSE 18555/udp
ENTRYPOINT ["/usr/local/bin/tonutils-storage-provider"]

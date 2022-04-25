# use a builder image for building cloudflare
ARG TARGET_GOOS
ARG TARGET_GOARCH
FROM golang:1.17.1 as builder
ENV GO111MODULE=on \
    CGO_ENABLED=0 \
    TARGET_GOOS=${TARGET_GOOS} \
    TARGET_GOARCH=${TARGET_GOARCH}

WORKDIR /go/src/github.com/cloudflare/cloudflared/

# copy our sources into the builder image
COPY . .

# compile cloudflared
RUN make cloudflared

# use an empty image, and rely on GoLang to manage binaries
FROM scratch

# copy required files into the container
COPY --from=builder /go/src/github.com/cloudflare/cloudflared/cloudflared .
COPY --from=builder /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/ca-certificates.crt 

# run as non-privileged user
USER nonroot

# command / entrypoint of container
ENTRYPOINT ["./cloudflared", "--no-autoupdate"]
CMD ["version"]

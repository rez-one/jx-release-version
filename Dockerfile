FROM golang:alpine as builder

RUN adduser -D -g '' appuser
RUN apk update && apk add git && apk add ca-certificates && apk add curl

COPY . $GOPATH/src/rez-one/jx-release-version
WORKDIR $GOPATH/src/rez-one/jx-release-version

ENV DEP_RELEASE_TAG=v0.5.0
RUN curl https://raw.githubusercontent.com/golang/dep/master/install.sh | sh 
RUN dep ensure

RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -a -installsuffix cgo -ldflags="-w -s" -o /go/bin/jx-release-version

FROM alpine/git
COPY --from=builder /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/
COPY --from=builder /etc/passwd /etc/passwd
COPY --from=builder /go/bin/jx-release-version /go/bin/jx-release-version
ENTRYPOINT ["/go/bin/jx-release-version"]

FROM golang:1.14.4-alpine AS builder

ENV GOPATH $GOPATH:/go
ENV PATH $PATH:$GOPATH/bin
    
RUN apk update
RUN apk --update add git openssh gcc musl-dev && \
    rm -rf /var/lib/apt/lists/* && \
    rm /var/cache/apk/* && \
    go get github.com/rubenv/sql-migrate/...

ENV GO111MODULE=on
ENV APP_MODE=production

ADD . /go/src/github.com/Tech-Design-Inc/vega
WORKDIR /go/src/github.com/Tech-Design-Inc/vega

RUN go build -o main main.go


FROM alpine:latest
ENV GOPATH=/go
WORKDIR $GOPATH/src/github.com/Tech-Design-Inc/vega
RUN mkdir db

RUN apk add --no-cache tzdata
COPY --from=builder /go/bin/sql-migrate sql-migrate
COPY --from=builder /go/src/github.com/Tech-Design-Inc/vega/main main
COPY --from=builder /go/src/github.com/Tech-Design-Inc/vega/dbconfig.yml dbconfig.yml
COPY --from=builder /go/src/github.com/Tech-Design-Inc/vega/db/migrations db/migrations

RUN chmod +x main

EXPOSE 8080
ENTRYPOINT ["./main"]

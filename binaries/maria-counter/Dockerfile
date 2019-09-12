FROM golang:1.12

COPY . /go/src/github.com/endocrimes/maria-counter

WORKDIR /go/src/github.com/endocrimes/maria-counter

RUN GO111MODULE=off go build -o /bin/maria-counter

ENTRYPOINT /bin/maria-counter

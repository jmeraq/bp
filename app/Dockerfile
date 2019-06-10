FROM golang:1.11
LABEL maintainer="Junior Mera <jmeraq@gmail.com>"
WORKDIR $GOPATH/src/microservice-bp
COPY ./app/ .
RUN go get -d -v ./...
RUN go install -v ./...
EXPOSE 80
CMD ["microservice-bp"]
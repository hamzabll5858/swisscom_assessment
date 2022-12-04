# ------- BASE IMAGE ------- #
FROM golang:1.18.3 AS base

WORKDIR /usr/src/app/

COPY go.mod go.sum ./
RUN go mod download && go mod verify

COPY . .

RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -a -installsuffix cgo -v -o build/movies-service .

# ------- EXECUTION IMAGE ------- #
FROM alpine:3.16.0

RUN apk --no-cache add ca-certificates

WORKDIR /build/

COPY --from=base /usr/src/app/build/movies-service .

# Non root user provisioning for least privilege
RUN addgroup -S  executor
RUN adduser -S executor -G executor
RUN chown -R executor:executor /build/
USER executor

EXPOSE 8080
CMD ["./movies-service"]
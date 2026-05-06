FROM golang:1.24-alpine3.21 AS builder

WORKDIR /src

COPY go.mod go.sum* ./
RUN go mod download

COPY . .
RUN CGO_ENABLED=0 GOOS=linux go build -ldflags="-s -w" -o /out/app .

FROM gcr.io/distroless/static-debian12:nonroot

WORKDIR /app

COPY --from=builder --chown=nonroot:nonroot /out/app ./app
COPY --from=builder --chown=nonroot:nonroot /src/web ./web

USER nonroot:nonroot

EXPOSE 8080

ENTRYPOINT ["/app/app"]

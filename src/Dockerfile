FROM public.ecr.aws/docker/library/golang:latest

WORKDIR /app

COPY . /app

RUN go mod init main

RUN go build -o main .

CMD ["/app/main"]

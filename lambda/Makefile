all: build

build:
	GOOS=linux GOARCH=amd64 go build main.go
	mkdir -p pkg
	zip pkg/rds-schedule-$(shell cat VERSION).zip main
	rm main

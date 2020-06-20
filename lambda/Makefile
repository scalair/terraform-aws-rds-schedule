all: build

build:
	GOOS=linux GOARCH=amd64 go build main.go
	mkdir -p $(shell cat VERSION)
	zip $(shell cat VERSION)/rds-schedule.zip main
	rm main

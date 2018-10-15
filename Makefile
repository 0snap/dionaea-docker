
build:
	docker build . -t fixel/dionaea-docker

run:
	docker run \
		-p 21:21 \
		-p 23:23 \
		-p 53:53 \
		-p 80:80 \
		-p 123:123 \
		-p 443:443 \
		-p 445:445 \
		-p 1443:1443 \
		-p 3306:3306 \
		-p 11211:11211 \
		-p 27017:27017 \
		--name dio --rm fixel/dionaea-docker

all: build run
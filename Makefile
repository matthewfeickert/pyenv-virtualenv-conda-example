default: image

all: image

image:
	docker pull debian:buster
	docker build . \
	--file Dockerfile \
	-t matthewfeickert/pyenv-virtualenv-conda:latest \
	--compress

test:
	docker pull debian:buster
	docker build . \
	--file Dockerfile \
	-t matthewfeickert/pyenv-virtualenv-conda:debug-local

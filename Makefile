default: image

all: image

image:
	docker build . \
	--pull \
	--file Dockerfile \
	-t matthewfeickert/pyenv-virtualenv-conda:latest \
	--compress

test:
	docker build . \
	--pull \
	--file Dockerfile \
	-t matthewfeickert/pyenv-virtualenv-conda:debug-local

default: image

all: image

image:
	docker build -f Dockerfile \
	--cache-from matthewfeickert/root-fastjet:latest \
	-t matthewfeickert/root-fastjet:latest \
	--compress .

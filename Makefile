build:
	packer init .
	packer build .

login:
	echo '${DOCKER_TOKEN}' | docker login --username akester --password-stdin

push-remote: login
	docker push akester/containername:latest

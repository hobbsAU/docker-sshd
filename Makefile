#Makefile for Docker container control

# Include additional variables
#include /srv/

# Define container repo and runtime name
CONTAINER_REPO = hobbsau/sshd
CONTAINER_RUN = sshd-service

# Define the exportable volumes for the container
CONFIG_VOL1 = /home/sshel
CONFIG_VOL2 = /etc/ssh

# This should point to the Docker host directory containing the config. The host directory must be owned by UID:GID 1000:1000. The format is '/host/directory:'
CONFIG_BIND1 = /srv/sshel/home:
CONFIG_BIND2 = /srv/sshel/etc:

# URL for triggering a rebuild
TRIGGER_URL = https://registry.hub.docker.com/u/hobbsau/sshd/trigger/edcdae8f-07c1-4012-800a-4361c05784c2/

# Trigger a remote initiated rebuild
build:
	echo "Rebuilding repository $(CONTAINER_REPO) ..."; 
	@curl --data build=true -X POST $(TRIGGER_URL) 

# Intantiate service continer and start it
run: 
	@if [ -z "`docker ps -a -q -f name=$(CONTAINER_RUN)`" ]; \
	then \
		echo "Checking for latest container..."; \
		docker pull $(CONTAINER_REPO); \
		echo "Creating and starting container..."; \
		docker run -d \
 		--restart=always \
 		-p 2222:22/tcp \
 		-v $(CONFIG_BIND1)$(CONFIG_VOL1) \
 		-v $(CONFIG_BIND2)$(CONFIG_VOL2) \
 		--name $(CONTAINER_RUN) \
 		$(CONTAINER_REPO); \
	else \
		echo "$(CONTAINER_RUN) is already running or a stopped container by the same name exists!"; \
		echo "Please try 'make clean' and then 'make run'"; \
	fi

# Start the service container. 
start:
	@if [ -z "`docker ps -q -f name=$(CONTAINER_RUN)`" ] && [ -n "`docker ps -a -q -f name=$(CONTAINER_RUN)`" ]; \
        then \
		echo "Starting container..."; \
		docker start $(CONTAINER_RUN); \
	else \
		echo "Container $(CONTAINER_RUN) doesn't exist or is already running!"; \
	fi

# Stop the service container. 
stop:
	@if [ -z "`docker ps -q -f name=$(CONTAINER_RUN)`" ]; \
        then \
		echo "Nothing to stop as container $(CONTAINER_RUN) is not running!"; \
	else \
		echo "Stopping container..."; \
		docker stop $(CONTAINER_RUN); \
	fi

# Service container is ephemeral so clean should be used with impunity.
clean: stop
	@if [ -z "`docker ps -a -q -f name=$(CONTAINER_RUN)`" ]; \
        then \
		echo "Nothing to remove as container $(CONTAINER_RUN) does not exist!"; \
	else \
		echo "Removing container..."; \
		docker rm $(CONTAINER_RUN); \
	fi

# Upgrade the container - may not work if rebuild takes too long
upgrade: build clean run

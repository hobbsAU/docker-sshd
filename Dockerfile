FROM alpine:3.17

LABEL 	org.opencontainers.image.authors="Adrian Hobbs <adrianhobbs@gmail.com>" \
	org.opencontainers.image.title="Docker SSH" \
	org.opencontainers.image.description="Alpine based SSH image with modern sshd_config"

ENV PACKAGES "openssh tzdata grep rsync"

# Install package using --no-cache to update index and remove unwanted files
RUN 	apk --no-cache --update upgrade && \
	apk --no-cache add $PACKAGES && \
	cp /usr/share/zoneinfo/UTC /etc/localtime && \
	echo "UTC" > /etc/timezone && \
	# Add a user to run as non root
	adduser -D -g '' sshel && \
	# Disable password-based access to an account while allowing SSH access
	sed -i "s/sshel:!/sshel:*/g" /etc/shadow && \
	sed -i "s/root:!/root:*/g" /etc/shadow
	# Disable root access
	# sed -i "s/root:/root:!/g" /etc/shadow

EXPOSE 22

CMD ["/usr/sbin/sshd", "-D", "-e"]


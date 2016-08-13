FROM alpine:edge
MAINTAINER Adrian Hobbs <adrianhobbs@gmail.com>
ENV PACKAGE "openssh tzdata"

# Install package using --no-cache to update index and remove unwanted files
RUN 	apk add --update --no-cache $PACKAGE && \
	cp /usr/share/zoneinfo/Australia/Sydney /etc/localtime && \
	echo "Australia/Sydney" > /etc/timezone && \
	# Add a user to run as non root
	adduser -D -g '' sshel

EXPOSE 22

CMD ["/usr/sbin/sshd","-D"]


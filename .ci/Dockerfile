FROM docker:18.09.9-rc1-dind
RUN apk --update add scons python

ENV DOCKER_HOST tcp://docker:2375/
ENV DOCKER_DRIVER overlay2
ENV DOCKER_TLS_CERTDIR=

ENTRYPOINT ["env", "-u", "DOCKER_HOST"]
CMD ["dockerd-entrypoint.sh"]

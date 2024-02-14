FROM alpine:latest
LABEL MAINTAINER="ek@ovos.at"
WORKDIR /opt
# Install dependencies
RUN apk update && \
    apk upgrade && \
    apk add jq && \
    apk add curl
# Check sha1sum and install kubectl
RUN sha1sum_kubectl_curl=`curl -s https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl | sha1sum | awk '{print $1}'`
RUN curl -LOs https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl
RUN sha1sum_kubectl_file=`sha1sum ./kubectl | awk '{print $1}'` 
RUN if [ "$sha1sum_kubectl_curl" != "$sha1sum_kubectl_file" ] ; then echo "sha1sum check faild" ; false ; fi
RUN chmod +x ./kubectl
RUN mv ./kubectl /usr/local/bin/kubectl

RUN adduser -D keepupdate
COPY --chown=keepupdate:keepupdate keep-update.sh .
RUN chown -R keepupdate:keepupdate /opt

USER keepupdate

ENTRYPOINT [ "sh", "keep-update.sh" ]

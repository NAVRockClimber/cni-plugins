FROM alpine
ARG version
ADD https://github.com/containernetworking/plugins/releases/download/v${version}/cni-plugins-linux-amd64-v${version}.tgz /
RUN mkdir /plugins && \
      tar -zxvf /cni-plugins-linux-amd64-v${version}.tgz -C /plugins && \
      rm /cni-plugins-linux-amd64-v${version}.tgz
CMD cp /plugins/* /opt/cni/bin
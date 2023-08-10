FROM alpine
ARG version
ARG TARGETARCH
COPY create-kubeconfig /
ADD https://github.com/containernetworking/plugins/releases/download/v${version}/cni-plugins-linux-${TARGETARCH}-v${version}.tgz /
RUN mkdir /plugins && \
      tar -zxvf /cni-plugins-linux-${TARGETARCH}-v${version}.tgz -C /plugins && \
      rm /cni-plugins-linux-${TARGETARCH}-v${version}.tgz
CMD cp /plugins/* /opt/cni/bin && \
    cp /create-kubeconfig /opt/cni/net.d/create-kubeconfig
FROM alpine
ARG version
ARG TARGETARCH
ADD https://github.com/containernetworking/plugins/releases/download/v${version}/cni-plugins-linux-${TARGETARCH}-v${version}.tgz /
RUN mkdir /plugins && \
      tar -zxvf /cni-plugins-linux-${TARGETARCH}-v${version}.tgz -C /plugins && \
      rm /cni-plugins-linux-${TARGETARCH}-v${version}.tgz
CMD cp /plugins/* /opt/cni/bin && \
    mkdir -p /opt/cni/net.d/multus.d && \
    SERVICEACCOUNT_CA=$(kubectl get secrets -n=kube-system -o json | jq -r '.items[]|select(.metadata.annotations."kubernetes.io/service-account.name"=="multus")| .data."ca.crt"') && \
    SERVICEACCOUNT_TOKEN=$(kubectl get secrets -n=kube-system -o json | jq -r '.items[]|select(.metadata.annotations."kubernetes.io/service-account.name"=="multus")| .data.token' | base64 -d ) && \
    KUBERNETES_SERVICE_PROTO=$(kubectl get all -o json | jq -r .items[0].spec.ports[0].name) && \
    KUBERNETES_SERVICE_HOST=$(kubectl get all -o json | jq -r .items[0].spec.clusterIP) && \
    KUBERNETES_SERVICE_PORT=$(kubectl get all -o json | jq -r .items[0].spec.ports[0].port) && \
    cat > /opt/cni/net.d/multus.d/multus.kubeconfig <<EOF \
    # Kubeconfig file for Multus CNI plugin. \
    apiVersion: v1 \
    kind: Config \
    clusters: \
    - name: local \
      cluster: \
        server: ${KUBERNETES_SERVICE_PROTOCOL:-https}://${KUBERNETES_SERVICE_HOST}:${KUBERNETES_SERVICE_PORT} \
        certificate-authority-data: ${SERVICEACCOUNT_CA} \
    users: \
    - name: multus \
      user: \
        token: "${SERVICEACCOUNT_TOKEN}"  \
    contexts:  \
    - name: multus-context  \
      context:  \
        cluster: local  \
        user: multus  \
    current-context: multus-context  \
    EOF  && \
    cat /opt/cni/net.d/multus.d/multus.kubeconfig
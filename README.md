# linkerd dashboard ingress

    kubectl apply --namespace linkerd -f linkerd.yml
    curl -sSL https://run.linkerd.io/install | sh
    curl -sSL https://run.linkerd.io/install-edge | sh
    linkerd install | kubectl apply -f -
    linkerd check
    curl -sL https://run.linkerd.io/emojivoto.yml | kubectl apply -f -
    kubectl apply --namespace linkerd -f linkerd.yml
    kubectl apply --namespace emojivoto -f emojivoto.yml
    kubectl get -n emojivoto deploy -o yaml | linkerd inject - | kubectl apply -f -


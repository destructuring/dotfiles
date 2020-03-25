# linkerd dashboard ingress
[![FOSSA Status](https://app.fossa.io/api/projects/git%2Bgithub.com%2Famanibhavam%2Fdotfiles.svg?type=shield)](https://app.fossa.io/projects/git%2Bgithub.com%2Famanibhavam%2Fdotfiles?ref=badge_shield)


    kubectl apply --namespace linkerd -f linkerd.yml
    curl -sSL https://run.linkerd.io/install | sh
    curl -sSL https://run.linkerd.io/install-edge | sh
    linkerd install | kubectl apply -f -
    linkerd check
    curl -sL https://run.linkerd.io/emojivoto.yml | kubectl apply -f -
    kubectl apply --namespace linkerd -f linkerd.yml
    kubectl apply --namespace emojivoto -f emojivoto.yml
    kubectl get -n emojivoto deploy -o yaml | linkerd inject - | kubectl apply -f -



## License
[![FOSSA Status](https://app.fossa.io/api/projects/git%2Bgithub.com%2Famanibhavam%2Fdotfiles.svg?type=large)](https://app.fossa.io/projects/git%2Bgithub.com%2Famanibhavam%2Fdotfiles?ref=badge_large)
VERSION --shell-out-anywhere --use-chmod --use-host-command --earthly-version-arg --use-copy-link --use-registry-for-with-docker 0.6

build:
    FROM ghcr.io/defn/dev:latest

    RUN git pull

    SAVE IMAGE --push 169.254.32.1:5000/workspace

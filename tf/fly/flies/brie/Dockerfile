FROM ghcr.io/defn/dev:latest-dev

RUN sudo apt update && sudo apt install -y docker.io make net-tools
RUN sudo ln -nfs /mnt/work /work
RUN cd && ln -nfs /work .
RUN cd && ln -nfs work/app .
RUN cd && touch .home.done
COPY service /service
RUN cd /home/ubuntu && sudo -u ubuntu git pull
RUN cd /home/ubuntu && make nix-reinstall && ./bin/e n profile install "github:defn/pkg?dir=caddy&ref=v0.0.56"
COPY flake.* .

USER root

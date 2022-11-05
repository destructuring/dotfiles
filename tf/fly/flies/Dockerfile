FROM ghcr.io/defn/dev:latest

RUN sudo install -d -m 0755 -o ubuntu -g ubuntu /nix
RUN sudo apt update && sudo apt install -y docker.io make xz-utils
RUN sudo ln -nfs /mnt/work /work
RUN cd && ln -nfs /work .
RUN cd && ln -nfs work/app .
RUN cd && touch .home.done
RUN cd /home/ubuntu && ./bin/e make nix-install
COPY service /service
ADD http://worldclockapi.com/api/json/utc/now /tmp/builddate
RUN cd /home/ubuntu && sudo -u ubuntu git pull

USER root

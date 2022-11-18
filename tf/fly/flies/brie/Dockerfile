FROM ghcr.io/defn/dev:latest-dev

RUN sudo apt update && sudo apt install -y docker.io make net-tools
RUN sudo ln -nfs /mnt/work /work
RUN cd && ln -nfs /work .
RUN cd && ln -nfs work/app .
RUN cd && touch .home.done
COPY service /service
ADD http://worldclockapi.com/api/json/utc/now /tmp/builddate
RUN cd /home/ubuntu && sudo -u ubuntu git pull
RUN cd /home/ubuntu && make nix-reinstall
COPY flake.* .

USER root

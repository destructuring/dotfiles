FROM ghcr.io/defn/dev:latest

RUN install -d -m 0755 -o ubuntu -g ubuntu /nix
RUN sudo apt update && sudo apt install -y openssh-server docker.io dnsutils make
RUN sudo ssh-keygen -A
RUN sudo ln -nfs /mnt/work /work
RUN cd && ln -nfs /work .
RUN cd && ln -nfs work/app .
RUN cd && touch .home.done
COPY service /service
ADD http://worldclockapi.com/api/json/utc/now /tmp/builddate
RUN cd /home/ubuntu && sudo -u ubuntu git pull

USER root

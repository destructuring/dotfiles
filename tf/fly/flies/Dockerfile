FROM ghcr.io/defn/dev:latest

RUN sudo ssh-keygen -A
RUN sudo ln -nfs /mnt/work /work
RUN cd && ln -nfs /work .
RUN cd && ln -nfs work/app .
RUN cd && touch .home.done
COPY service /service
RUN git pull

USER root

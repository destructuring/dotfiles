FROM quay.io/defn/dev

RUN sudo ssh-keygen -A
RUN sudo ln -nfs /mnt/work /work
COPY service /service

USER root

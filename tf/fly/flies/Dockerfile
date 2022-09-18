FROM quay.io/defn/dev

RUN sudo ssh-keygen -A
RUN sudo ln -nfs /mnt/work /work
RUN cd && ln -nfs /work .
RUN cd && ln -nfs work/app .
RUN cd && touch .done
COPY service /service

USER root

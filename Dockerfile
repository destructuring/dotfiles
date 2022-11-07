FROM ghcr.io/defn/dev:latest-dev

ADD http://worldclockapi.com/api/json/utc/now /tmp/builddate
RUN git pull

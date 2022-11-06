FROM ghcr.io/defn/dev:latest

ADD http://worldclockapi.com/api/json/utc/now /tmp/builddate
RUN git pull

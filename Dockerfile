FROM ubuntu
# Adding build tools to make yarn install work on Apple silicon / arm64 machines
WORKDIR /app
COPY . .
RUN bash install2.sh
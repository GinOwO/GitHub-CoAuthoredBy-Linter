FROM alpine:latest

RUN apk update && \
    apk add --no-cache git bash

COPY ./entry.sh /usr/local/bin/entry.sh

RUN chmod +x /usr/local/bin/entry.sh

CMD ["/usr/local/bin/entry.sh"]

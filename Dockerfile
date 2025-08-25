FROM debian:stable-slim

RUN apt-get update && \
  apt-get install -y --no-install-recommends ca-certificates curl jq
ADD checklists /checklists
ADD entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]

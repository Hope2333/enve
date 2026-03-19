FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

COPY scripts/ci/install-linux-build-deps.sh /tmp/install-linux-build-deps.sh
RUN chmod +x /tmp/install-linux-build-deps.sh && \
    /tmp/install-linux-build-deps.sh && \
    rm -f /tmp/install-linux-build-deps.sh

WORKDIR /workspace

CMD ["/bin/bash"]

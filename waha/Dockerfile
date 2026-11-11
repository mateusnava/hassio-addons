# Home Assistant passes BUILD_ARCH (aarch64 or amd64) when building the add-on.
# WAHA publishes one tag per architecture, so pick the matching base stage.
ARG BUILD_ARCH=amd64
ARG WAHA_VERSION=2026.10.1

FROM devlikeapro/waha:latest-${WAHA_VERSION} AS base-amd64
FROM devlikeapro/waha:arm-${WAHA_VERSION} AS base-aarch64

FROM base-${BUILD_ARCH}

ENV WAHA_DEFAULT_SESSION=default
ENV WAHA_LOCAL_STORE_BASE_DIR=/data/.sessions

COPY run.sh /run.sh
RUN chmod +x /run.sh

# Keep the image's tini entrypoint; run.sh loads the add-on options, then starts WAHA.
CMD ["/run.sh"]

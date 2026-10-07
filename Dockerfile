# GitHub Actions self-hosted runner: the official release binaries on Debian slim.
# Not Alpine: the runner and the Node.js it bundles for actions are built for glibc only.

FROM debian:13.7-slim@sha256:a29215f6a35e51e22adffa17f89e9d2ef06214e64a2bad10d765c46aea49f11f AS download
ARG TARGETARCH
# https://github.com/actions/runner/releases (SHA256 from the release notes)
ARG RUNNER_VERSION=2.338.0
ARG RUNNER_SHA256_x64=af4b794c1bc41d73d40535e3fe092a39f9679cd8d965954c2aca25a05ca41d32
ARG RUNNER_SHA256_arm64=628b4a7258487b80c1d3c221095a7ded349f5ae0175fd3dfab708d07428f041b
RUN apt-get update \
 && apt-get install -y --no-install-recommends ca-certificates curl \
 && rm -rf /var/lib/apt/lists/*
RUN set -eu; \
    case "$TARGETARCH" in amd64) arch=x64 sha=$RUNNER_SHA256_x64 ;; arm64) arch=arm64 sha=$RUNNER_SHA256_arm64 ;; *) exit 1 ;; esac; \
    curl -fsSLo /runner.tar.gz "https://github.com/actions/runner/releases/download/v${RUNNER_VERSION}/actions-runner-linux-${arch}-${RUNNER_VERSION}.tar.gz"; \
    echo "$sha  /runner.tar.gz" | sha256sum -c -; \
    mkdir /runner && tar -xzf /runner.tar.gz -C /runner

FROM debian:13.7-slim@sha256:a29215f6a35e51e22adffa17f89e9d2ef06214e64a2bad10d765c46aea49f11f
# What the runner needs (bin/installdependencies.sh) plus git for actions/checkout.
RUN apt-get update \
 && apt-get install -y --no-install-recommends ca-certificates git libicu76 libkrb5-3 libssl3t64 zlib1g \
 && rm -rf /var/lib/apt/lists/* \
 && useradd --create-home --uid 1001 runner \
 && install -d -o runner -g runner /state
COPY --from=download --chown=runner:runner /runner /home/runner/actions-runner
COPY --chmod=755 entrypoint.sh /entrypoint.sh
USER runner
WORKDIR /home/runner/actions-runner
# Registration, kept across restarts.
VOLUME /state
ENTRYPOINT ["/entrypoint.sh"]

# Devcontainer of this fork: stage "dev" (see devcontainer.json). Only the fork has this file;
# upstream's Dockerfile in src/home-mind-server builds the app and stays as it is. Keep the Node
# major in step with the FROM line there.
FROM node:24.22.3-bookworm-slim AS dev
ENV NPM_CONFIG_UPDATE_NOTIFIER=false NPM_CONFIG_FUND=false

# better-sqlite3 compiles from source when no prebuilt binary fits. User dev (UID 1000) is the
# image's user node renamed; Claude Code, git, just and dev-kit come from the dev-kit feature.
RUN apt-get update \
    && apt-get install -y --no-install-recommends python3 make g++ \
    && rm -rf /var/lib/apt/lists/* \
    && usermod --login dev --move-home --home /home/dev node \
    && groupmod --new-name dev node
USER dev

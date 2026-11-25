# Development commands of this fork. Only the fork has this file; upstream has none. Skills and
# scripts call these recipes, not the tools.

# List the recipes
default:
    @just --list

# Type check and tests of the server
check:
    cd src/home-mind-server && npm run typecheck && npm test

# Show what upstream has that this fork does not, and whether merging it conflicts
fork-sync:
    dev-kit fork-sync

# Deploy origin/main (a fork has no releases) and wait for the webhook's answer; the devcontainer
# cannot push, so push main first on the host with: dev-kit-host push home-mind main
deploy:
    dev-kit deploy --fork

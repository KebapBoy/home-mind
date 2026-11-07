#!/bin/sh
# Fix data volume ownership, then drop to PUID:PGID (default 1000, the uid of
# the official shodh image) so bind-mounted data stays owned by the host user.
PUID="${PUID:-1000}"
PGID="${PGID:-1000}"

if [ -d /data ] && [ "$(stat -c '%u:%g' /data)" != "${PUID}:${PGID}" ]; then
  echo "[entrypoint] Fixing /data ownership for ${PUID}:${PGID}..."
  chown -R "${PUID}:${PGID}" /data
fi

# --clear-groups, not --init-groups: the latter needs a passwd entry for the uid,
# which an arbitrary PUID does not have inside the image.
exec setpriv --reuid="${PUID}" --regid="${PGID}" --clear-groups "$@"

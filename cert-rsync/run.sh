#!/usr/bin/with-contenv bash
set -e

OPTIONS="/data/options.json"

CONFIG_PATH="/data"
SSH_DIR="${CONFIG_PATH}/.ssh"
KEY_FILE="${SSH_DIR}/id_ed25519"
KNOWN_HOSTS_FILE="${SSH_DIR}/known_hosts"


REMOTE_USER=$(jq -r '.remote_user' "$OPTIONS")
REMOTE_HOST=$(jq -r '.remote_host' "$OPTIONS")
REMOTE_PATH=$(jq -r '.remote_path' "$OPTIONS")
LOCAL_PATH=$(jq -r '.local_path' "$OPTIONS")
SSH_PORT=$(jq -r '.ssh_port' "$OPTIONS")
SYNC_INTERVAL=$(jq -r '.sync_interval' "$OPTIONS")

SUPERVISOR_API="http://supervisor/core/restart"

mkdir -p "${SSH_DIR}"
chmod 700 "${SSH_DIR}"

### Generate SSH key if missing
if [ ! -f "${KEY_FILE}" ]; then
  echo "[INFO] Generating SSH key..."
  ssh-keygen -t ed25519 -N "" -f "${KEY_FILE}"
  echo "[INFO] Public key (add to remote server):"
  cat "${KEY_FILE}.pub"
fi



if [ ! -f "$KNOWN_HOSTS_FILE" ]; then
  ssh-keyscan -p "${SSH_PORT}" "${REMOTE_HOST}" >> "$KNOWN_HOSTS_FILE" 2>/dev/null || true
  chmod 600 "$KNOWN_HOSTS_FILE"
fi



### Main loop
while true; do
  echo "[INFO] Starting certificate sync..."

  RSYNC_OUTPUT=$(
    rsync -az --delete --itemize-changes --chown=root:root \
      -e "ssh -p ${SSH_PORT} -i ${KEY_FILE} -o StrictHostKeyChecking=yes" \
      "${REMOTE_USER}@${REMOTE_HOST}:${REMOTE_PATH}" \
      "${LOCAL_PATH}/" || true
  )

  if echo "${RSYNC_OUTPUT}" | grep -qE '^[<>ch\*]'; then
    echo "[INFO] Certificate changes detected"
    echo "[INFO] Restarting Home Assistant Core..."

    curl -s -X POST \
      -H "Authorization: Bearer ${SUPERVISOR_TOKEN}" \
      "${SUPERVISOR_API}"

  else
    echo "[INFO] No certificate changes detected"
  fi

  sleep "${SYNC_INTERVAL}"
done

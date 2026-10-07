#!/bin/bash
# Registers the runner on first start, then runs it. The registration is kept in
# /state, so later starts need no token.
set -euo pipefail

files=(.runner .credentials .credentials_rsaparams)

if [[ ! -f /state/.runner ]]; then
  : "${RUNNER_URL:?the repository URL, e.g. https://github.com/owner/repo}"
  : "${RUNNER_TOKEN:?a registration token: repo Settings > Actions > Runners > New self-hosted runner}"
  # --disableupdate: the version is pinned in the image; new versions come as new images.
  ./config.sh --unattended --replace --disableupdate \
    --url "$RUNNER_URL" --token "$RUNNER_TOKEN" \
    --name "${RUNNER_NAME:-$(hostname)}" --labels "${RUNNER_LABELS:-}" \
    --work /tmp/_work
  mv "${files[@]}" /state/
fi

for f in "${files[@]}"; do ln -sf "/state/$f" "$f"; done

# Jobs don't need the token.
unset RUNNER_TOKEN
exec ./run.sh

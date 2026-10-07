# gh.runner

A GitHub Actions self-hosted runner image: the official
[actions/runner](https://github.com/actions/runner) release binaries (checksum
verified) on `debian:13.7-slim`, for `linux/arm64` and `linux/amd64`.

```
ghcr.io/feruzabad/gh.runner:<runner version>
```

Not Alpine: the runner and the Node.js it bundles for actions are built for glibc only.

## The image

- Runs as the unprivileged user `runner` (uid 1001). No sudo, no Docker CLI.
- Self-updates are off (`--disableupdate`): a new runner version is a new image.
- Besides the runner's own libraries it only has `git` (for `actions/checkout`).
  Jobs that need more tools install them in the job or use a different image.

## Running it

First start registers the runner, later starts reuse the registration in `/state`.

| Variable | |
|---|---|
| `RUNNER_URL` | the repository, e.g. `https://github.com/feruzabad/apollo.stack` |
| `RUNNER_TOKEN` | registration token from Settings > Actions > Runners > New self-hosted runner. Expires after an hour and is only needed for the first start. |
| `RUNNER_NAME` | optional, defaults to the container host name |
| `RUNNER_LABELS` | optional, comma separated, added to `self-hosted,Linux,ARM64` |

Keep `/state` on a volume. To register again, remove the volume.

**Only register it with private repositories.** On a public repository anyone can open a
pull request whose workflow runs on your runner.

## Building

`.github/workflows/build.yaml` builds and pushes on every change to `main` to
`Dockerfile`, `entrypoint.sh` or the workflow, or by hand (Actions > build > Run
workflow). Pull requests don't run it. To update the runner, change `RUNNER_VERSION`
and both `RUNNER_SHA256_*` in the `Dockerfile` (SHA256 values from the release notes).

## License

[MIT](LICENSE)

# Releasing

The usual path is `.github/workflows/release.yml`: release-please opens a release
PR, merging it tags the release, and the workflow publishes to npm. When GitHub
Actions can't run, do the same steps by hand. The versions and the CHANGELOG
still come from release-please, so the two paths don't drift.

Needs: Node 18+, the GitHub CLI signed in with push rights (`gh auth status`),
and an npm account with publish rights on `@tansuasici/claude-marketing-kit`.

## 1. Check main

```bash
git checkout main && git pull
bash scripts/validate.sh
```

`scripts/validate.sh` runs the same checks as `.github/workflows/validate.yml`.
Run it before every push while Actions are off, since nothing else runs them.

## 2. Open the release PR

```bash
npx release-please@17 release-pr \
  --token="$(gh auth token)" \
  --repo-url=tansuasici/claude-marketing-kit \
  --config-file=release-please-config.json \
  --manifest-file=.release-please-manifest.json
```

Add `--dry-run` first to see the version and CHANGELOG it would write. The PR
bumps `VERSION`, `package.json`, `.claude-plugin/plugin.json` and
`.claude-plugin/marketplace.json`, and writes `CHANGELOG.md`. Don't edit those by
hand.

## 3. Merge it and tag

Review and squash-merge the release PR, then create the tag and GitHub release
from the merged commit:

```bash
git checkout main && git pull
npx release-please@17 github-release \
  --token="$(gh auth token)" \
  --repo-url=tansuasici/claude-marketing-kit \
  --config-file=release-please-config.json \
  --manifest-file=.release-please-manifest.json
```

## 4. Publish to npm

From the tagged main:

```bash
bash scripts/validate.sh
npm publish --access public
```

npm asks you to confirm in the browser (or for a one-time code). Then check that
the registry and the plugin manifest agree:

```bash
npm view @tansuasici/claude-marketing-kit version
jq -r .version .claude-plugin/plugin.json
```

## 5. Refresh the docs site

The docs site reads the version, CHANGELOG and skill docs from this repo at build
time, so redeploy it after the release. In the workflow path the release fires
this automatically.

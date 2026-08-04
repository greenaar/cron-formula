# cron formula

Install cron, manage crontab entries and environment variables from pillar,
and make sure the service is running.

## Scope

- OS: Debian 12 (bookworm) / 13 (trixie), Ubuntu 24.04+ (both grain
  `os_family: Debian`, both use the `cron` package and `cron` service)
- Salt: 3008+

### What changed from the previous version

**Trimmed the map layers to what's actually used.** The old `map.jinja`
merged four grain-keyed layers: `osarchmap.yaml`, `osfamilymap.yaml`,
`osmap.yaml`, `osfingermap.yaml`. `osarchmap.yaml` set an `arch` key that
no state in this formula ever read - dead config. `osfingermap.yaml` was
an empty stub. Both are gone. `osfamilymap.yaml`/`osmap.yaml` stay as thin
extension points (now Debian/Ubuntu only) in case Debian and Ubuntu ever
need different package/service names, matching the pattern used in the
`salt`/`apt` formulas in this repo.

**State ID namespacing.** `cron.install`, `cron.service`, `cron.<task>`,
and `cron.<env>` are now `cron-package-install`, `cron-service-running`,
`cron-task-<task>`, `cron-env-<env>` - consistent dash-based naming with
the rest of this repo's formulas, and namespaced against collisions with
any other formula that might also define an ID matching a bare task name.

**Explicit `require`s added.** Nothing previously enforced that the `cron`
package gets installed before the `cron.present`/`cron.env_*`/service
states run - it happened to work because Salt executes states in the
order they're compiled and `init.sls` includes `.package` before
`.config`/`.service`, but that's an implicit ordering dependency that
silently breaks if the includes are ever reordered. `cron-task-*`,
`cron-env-*`, and `cron-service-running`/`-dead` all now explicitly
`require: - pkg: cron-package-install`.

**Fixed a stray whitespace bug.** `cron.get('env', {}). items()` (note the
space before `.items()`) rendered fine under current Jinja but was cleaned
up for clarity, in both `config/file.sls` and the saltcheck test.

**saltcheck tests trimmed to Debian/Ubuntu.** The `crond`/`cronie`/Arch/
Suse branches in `saltcheck-tests/package/install.tst` and
`saltcheck-tests/service/running.tst` are gone; both now assert against
the `cron` package/service directly.

## Usage

```yaml
include:
  - cron
```

Includes `.package`, `.config`, `.service`.

## Pillar reference

```yaml
cron:
  enabled: true      # false -> service.dead instead of service.running
  # pkg / service default to 'cron' / 'cron' - only override if you know
  # you need to (e.g. pointing at a fork/alternate package).

  tasks:
    nightly-backup:
      name: /usr/local/bin/backup.sh
      user: root
      minute: '0'
      hour: '2'
      comment: Nightly backup

    old-task:
      type: absent
      name: /usr/local/bin/old-backup.sh
      user: root

  env:
    mailto:
      name: MAILTO
      value: ops@example.com

    unused-var:
      type: absent
      name: SOME_OLD_VAR
```

Each key under `tasks` maps to one `cron.present` (default) or
`cron.absent` (`type: absent`) state, keyed by an arbitrary name used as
the cron entry's `identifier` (so re-running with edited schedule/command
updates the same entry rather than adding a duplicate). Valid fields:
`name` (the command), `user` (default `root`), `minute`, `hour`,
`daymonth`, `month`, `dayweek`, `comment`, `special` (a special string
like `@reboot` instead of minute/hour/etc), `commented` (deploy the entry
disabled).

Each key under `env` maps to one `cron.env_present` (default) or
`cron.env_absent` (`type: absent`) state - crontab environment variable
lines like `MAILTO=ops@example.com`.

## Relationship to upstream

**This is a heavily modified fork of
[`saltstack-formulas/cron-formula`](https://github.com/saltstack-formulas/cron-formula). Do not treat it as a drop-in
replacement for it.**

States have been renamed, split, merged, and removed; pillar keys have moved;
defaults differ; and behaviour has changed in ways that are not backward
compatible. Pointing an existing deployment at this formula without reading
`pillar.example` and the state list above will not do what you expect.

It is also not a newer version of upstream — it diverged and was maintained
separately, so upstream may well have fixes and platform support that this
does not. If you want the maintained original, use
[`saltstack-formulas/cron-formula`](https://github.com/saltstack-formulas/cron-formula).

### Credit

The foundation of this formula, and much of what still works well in it, is
the work of the [saltstack-formulas](https://github.com/saltstack-formulas) authors and contributors. Any
bugs introduced in the divergence are this fork's own.

Specific third-party files bundled here, with their own authors and
licenses, are itemised in [THIRD-PARTY.md](THIRD-PARTY.md).

## License

Dedicated to the public domain under [CC0 1.0 Universal](LICENSE), with the
exception of the third-party files listed in [THIRD-PARTY.md](THIRD-PARTY.md).

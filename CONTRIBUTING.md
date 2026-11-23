# Contributing

## Branches
- `main`: stable, always working
- `feature/<name>`: new work (e.g. `feature/night-mode`)
- `fix/<name>`: bug fixes

Open a Pull Request into `main`; do not push to `main` directly.

## Commit messages
Use the form `type: short description`:

- `feat: add garage state machine`
- `fix: reconnect on wifi loss`
- `docs: update MQTT contract`
- `chore: bump PubSubClient version`

## Contract changes
Any change to topics or payloads must update `docs/mqtt-contract.md` in the
same PR, so the app and firmware never drift apart.

## Secrets
Never commit `config.h`, passwords or broker credentials.

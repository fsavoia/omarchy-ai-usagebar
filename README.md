# omarchy-ai-usagebar

Live quota in the native Omarchy agents panel for vendors Omarchy does not
already cover, sourced from [ai-usagebar](https://github.com/akitaonrails/ai-usagebar).

![The Command Code tab in the Omarchy agents panel](./preview.png)

## Prerequisite — ai-usagebar (required)

This plugin **does nothing on its own**. It is an adapter: it reads
`ai-usagebar usage --json` and translates it into the Omarchy agents-panel
record format. All authentication and quota fetching — talking to each
provider's API — is done by ai-usagebar. No ai-usagebar, no data.

Install ai-usagebar first (any one):

```bash
mise use -g github:akitaonrails/ai-usagebar   # no Rust toolchain needed
cargo install ai-usagebar                      # from source
# or a prebuilt binary: github.com/akitaonrails/ai-usagebar/releases/latest
```

Then enable the vendor you want in `~/.config/ai-usagebar/config.toml`:

```toml
[commandcode]
enabled = true
```

Verify ai-usagebar works before installing the plugin:

```bash
ai-usagebar --vendor commandcode --pretty
```

If `ai-usagebar` is missing or a vendor is disabled, this plugin writes no
record for it and the panel simply shows no tab.

## Requirements

- Omarchy, with the `omarchy.agents` bar widget in the layout.
- ai-usagebar (above), reachable on `PATH` — or at
  `~/.local/share/mise/shims/ai-usagebar`.
- `python3`.

## Install

```bash
omarchy plugin add https://github.com/fsavoia/omarchy-ai-usagebar.git --enable
```

## Coverage

Every ai-usagebar vendor that Omarchy does not already collect. Vendors with a
richer built-in collector are skipped on purpose, so their tabs are never
overwritten with thinner data:

| ai-usagebar vendor | Native Omarchy collector | Handled here |
|---|---|---|
| anthropic | `claude` (limits + transcripts) | no |
| openai | `codex` | no |
| fireworks | `fireworks` (billing ledger) | no |
| commandcode | — | **yes** |
| copilot, zai, openrouter, … | — | yes, when enabled |

## Conflicts

`dell.commandcode-usage` writes the same `commandcode.json` from local session
stats. Run one or the other: this plugin owns the quota and credits, that one
owns the local token charts. Remove it with
`omarchy plugin remove dell.commandcode-usage`.

## How it works

- `bin/ai-usagebar-collect` runs `ai-usagebar usage --json`, maps each ready
  vendor to an agents-panel record (`limits[]` from the window metrics,
  `balance` from the credit ledger), and writes `<vendor>.json` atomically.
- `ui/main.qml` runs the collector every 5 minutes and at startup.
- Nothing outside `~/.local/state/omarchy/agents/usage/` is touched.

## Manual test

```bash
~/.config/omarchy/plugins/fsavoia.ai-usagebar/bin/ai-usagebar-collect          # print records
~/.config/omarchy/plugins/fsavoia.ai-usagebar/bin/ai-usagebar-collect --write
jq . ~/.local/state/omarchy/agents/usage/commandcode.json
omarchy plugin validate ~/.config/omarchy/plugins/fsavoia.ai-usagebar
omarchy-shell shell rescanPlugins
```

## License

MIT

# omarchy-ai-usagebar

Live quota in the native Omarchy agents panel for vendors Omarchy does not
already cover, sourced from [ai-usagebar](https://github.com/akitaonrails/ai-usagebar).

The Omarchy agents panel (`omarchy.agents`) draws whatever JSON records appear in
`~/.local/state/omarchy/agents/usage/`. This plugin runs `ai-usagebar usage --json`,
maps each vendor into that record schema, and writes one record per vendor, so the
panel renders the meters and the credit balance natively — same look as Claude and
Codex.

## Why

Command Code exposes no public quota endpoint, so Omarchy's own collectors cannot
show its limits. ai-usagebar does know them (5h/weekly/monthly windows plus the
credit ledger). This plugin pipes that into the panel.

## Requirements

- Omarchy, with the `omarchy.agents` panel in the bar.
- [ai-usagebar](https://github.com/akitaonrails/ai-usagebar) on `PATH` (or at
  `~/.local/share/mise/shims/ai-usagebar`).
- `python3`.

## Install

```bash
omarchy plugin add https://github.com/fsavoia/omarchy-ai-usagebar.git --enable
```

Enable the vendors you want in ai-usagebar's config (`~/.config/ai-usagebar/config.toml`):

```toml
[commandcode]
enabled = true
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

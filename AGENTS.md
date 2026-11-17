# Maintaining duo-kit

Instructions for an agent or a person keeping this repository current. The plugin's value is that its claims about iPhone Duo are true for the SDK people have installed, so most maintenance is re-verification.

## Layout

- `skills/<name>/SKILL.md` — the nine skills. Each carries a copy of the card in `shared/not-an-ipad.md`, between `duo-kit:card` markers.
- `skills/<name>/references/`, `scripts/` — detail and helper scripts a skill points to.
- `agents/` — two thin Claude Code agents. All logic stays in the skills so Codex behaves the same.
- `fixtures/DuoBookSample/` — the sample app that proves the book layout and produces `docs/images/`.
- `evals/trigger-prompts.md` — the 15 prompts and the results of each run.
- `provenance.json` — what was verified, with which Xcode, and a hash of every skill file.
- `.claude-plugin/`, `.codex-plugin/` — manifests. Keep the two versions equal.

## Checks to run before every commit

```bash
python3 scripts/duokit.py sync       # after editing shared/not-an-ipad.md
python3 scripts/duokit.py lint
python3 scripts/duokit.py snippets   # type-checks every Swift block in skills/
```

All three must pass. `lint` also fails if `fixtures/DuoBookSample/BookSpread.swift` and its copy in `skills/duo-book-layout/references/book-spread.md` differ: edit the fixture, then paste it into the reference.

## When a new Xcode or iOS SDK ships

1. Run `snippets` against the new SDK. A failure means an API was renamed or removed: fix the skill text and the code together.
2. Check the names the skills mention only in prose (UIKit equivalents, option names) against the SDK's interface files.
3. Rebuild `fixtures/DuoBookSample` with `build.sh`, run it on an iPhone Duo simulator, and repeat the poses in `skills/duo-pose-testing/SKILL.md`. Compare what the probe screen reports with the numbers quoted in `duo-book-layout`, `duo-fold-and-poses` and `duo-adaptive-layout`. Update numbers that changed, and say which SDK they came from.
4. Re-check the simulator facts in `duo-pose-testing`: which runtimes accept the device type, whether a screenshot needs a display id, which Xcode has the hinge test API.
5. Update `provenance.json` (Xcode build, date, file hashes) and add a `CHANGELOG.md` entry.

## When Apple's guidance changes

Sources are listed in `skills/duo-app-readiness/references/sources.md`. Re-read the Human Interface Guidelines page and the overview article when Apple updates them. Paraphrase and link; never paste Apple's text. If Apple's rule and this plugin's book-layout convention drift apart, keep the two clearly labelled in `duo-book-layout`.

## When Duo Gallery changes

`skills/duo-design-references/references/duo-gallery.md` describes the site's labels, states and query methods as read on a given date. Re-read the site and update the description and the date. Never add a list of optimized apps to the repository, and never add screenshots from it.

## Rules that do not change

- Skills are self-contained and harness-neutral: no other plugin's name, no harness-specific tool name. The lint enforces a banned-term list.
- An API statement names the SDK it was checked against. A measurement is labelled as a measurement and never written into code as a constant.
- Third-party code or text enters only under a licence that allows it, with the notice added to `THIRD_PARTY_NOTICES.md`.
- Every skill description mentions iPhone Duo and names the task. After changing a description, re-run the affected prompts in `evals/trigger-prompts.md` in a fresh session and record the result.
- Do not report something as verified unless it was run. `provenance.json` and the README list what was not.

## Releasing

1. Bump `version` in `.claude-plugin/plugin.json`, `.claude-plugin/marketplace.json` and `.codex-plugin/plugin.json`, and `package_version` in `provenance.json`.
2. Add the `CHANGELOG.md` entry.
3. Run the three checks.
4. Commit, tag `v<version>`, push, and publish a GitHub release whose notes are that changelog entry.

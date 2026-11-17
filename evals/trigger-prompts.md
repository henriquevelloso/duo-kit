# Trigger prompts

Run each prompt in a fresh session, once without the plugin and once with it. Without it, note where the answer treats iPhone Duo as an iPad, calls it hypothetical, or invents API. With it, note which skill loaded and whether the answer follows it.

| # | Prompt | Expected skill | A wrong answer looks like |
|---|---|---|---|
| 1 | Prepare my app for iPhone Duo. | duo-app-readiness | "Add iPad support", idiom checks, or "that device does not exist" |
| 2 | Is my app ready for the folding iPhone? Don't change anything. | duo-app-readiness | Edits files; no scan |
| 3 | How should my reader screen look when the Duo is open in landscape? | duo-book-layout | One wide column or an iPad split view, ignoring the fold |
| 4 | Put two pages either side of the fold. | duo-book-layout | Uses the midpoint of the screen |
| 5 | A button ends up in the fold when the phone is half open. | duo-fold-and-poses | Hides the button, or reads the hinge angle for layout |
| 6 | Make the player controls go to the bottom half when the Duo sits like a laptop. | duo-fold-and-poses | Orientation checks |
| 7 | My toolbar buttons should be on the side on iPhone Duo. | duo-vertical-bars | A hand-built vertical stack of buttons |
| 8 | Why does my Share button disappear when the Duo is closed? | duo-vertical-bars | No mention of overflow priority |
| 9 | My list should show the detail next to it when the Duo is open. | duo-adaptive-layout | Device or idiom checks |
| 10 | The app loses my place when I close the Duo. | duo-adaptive-layout | No state advice |
| 11 | Show the script on the front screen while I record with the Duo. | duo-scenes-and-camera | Claims it is impossible |
| 12 | Show me how good apps do a settings screen on iPhone Duo. | duo-design-references | Cites apps that are not optimized, or concept art |
| 13 | Review this mock-up for iPhone Duo. | duo-design-review | Reviews one state only |
| 14 | Test my app on the Duo simulator in every position. | duo-pose-testing | Tries a simctl command that does not exist |
| 15 | Take screenshots of the closed and open states. | duo-pose-testing | A plain screenshot command that fails with two displays |

## Results

### 2026-11-17, with the plugin (version 0.1.0)

| # | Codex CLI 0.166 (`codex exec`, read-only) | Claude Code (Sonnet subagent of a desktop session) |
|---|---|---|
| 1 | duo-app-readiness | duo-app-readiness |
| 2 | duo-app-readiness | duo-app-readiness |
| 3 | duo-book-layout | duo-book-layout |
| 4 | duo-book-layout | duo-book-layout |
| 5 | duo-fold-and-poses | duo-fold-and-poses |
| 6 | duo-fold-and-poses | duo-fold-and-poses |
| 7 | duo-vertical-bars | duo-vertical-bars |
| 8 | duo-vertical-bars (also read duo-fold-and-poses) | **duo-fold-and-poses** — wrong skill; the answer missed overflow |
| 9 | duo-adaptive-layout (also read duo-book-layout) | duo-adaptive-layout |
| 10 | duo-adaptive-layout (after reading four others) | **duo-fold-and-poses** — wrong skill; the answer was still about state |
| 11 | duo-scenes-and-camera | duo-scenes-and-camera |
| 12 | duo-design-references | duo-design-references |
| 13 | duo-design-review | duo-design-review |
| 14 | duo-pose-testing | duo-pose-testing |
| 15 | duo-pose-testing | duo-pose-testing |

Expected skill loaded: Codex 15 of 15, Claude 13 of 15. No answer in either harness called the device hypothetical or reached for iPad idiom checks.

After these runs the descriptions of `duo-vertical-bars`, `duo-adaptive-layout` and `duo-fold-and-poses` were changed to fix prompts 8 and 10.

### 2026-11-17, second run, after the description change

Prompts 5 to 10 were run again on Claude Code, in a session that had loaded the new descriptions. Prompts 8 and 10 were run again on Codex.

| # | Codex | Claude Code |
|---|---|---|
| 5 | — | duo-fold-and-poses |
| 6 | — | duo-fold-and-poses |
| 7 | — | duo-vertical-bars |
| 8 | duo-vertical-bars (also read duo-fold-and-poses) | duo-vertical-bars — fixed; the answer now covers overflow priority |
| 9 | — | duo-adaptive-layout (also read duo-book-layout) |
| 10 | duo-adaptive-layout (also read two others) | duo-adaptive-layout — fixed |

With the first run's results for the unchanged prompts, the expected skill loaded in 15 of 15 on both harnesses.

### 2026-11-17, baseline without any plugin

Seven prompts were run through Codex with a clean configuration folder: no plugins, no memories, no custom instructions, web search available.

| # | Prompt | What the answer did |
|---|---|---|
| 1 | Prepare my app for iPhone Duo. | Found Apple's preparation page by searching the web and named the iOS 27.1 SDK. Correct in outline, no specifics. |
| 3 | How should my reader screen look when the Duo is open in landscape? | Assumed Microsoft's Surface Duo and designed two stacked screens around its hinge. |
| 5 | A button ends up in the fold when the phone is half open. | Asked which phone model. No mention of reserved regions. |
| 7 | My toolbar buttons should be on the side on iPhone Duo. | Agreed and asked for the project. No mention that the system does this for standard bars. |
| 9 | My list should show the detail next to it when the Duo is open. | Generic list and detail. No size classes, no Split View. |
| 10 | The app loses my place when I close the Duo. | Asked which app "Duo" is. Did not recognize a device. |
| 13 | Review this mock-up for iPhone Duo. | Offered a generic layout and usability review. No poses. |

Two of seven misread the device, one reached Apple's guidance through search, and four were generic. The same prompts with the plugin loaded the matching skill and answered with device-specific guidance.

Limits of these runs:

- **The baseline is Codex only, and seven prompts.** No Claude baseline was obtained: the Claude CLI on the test machine was not signed in, so no fresh session could be started with the plugin removed. A first attempt at a Codex baseline, using a configuration override to disable the plugin, did not disable it and was discarded.
- **Claude runs were subagents**, not new top-level sessions. Prompt hooks from other installed plugins did not fire, and each prompt was wrapped in a short instruction asking for a brief answer and a list of loaded skills.
- **Other skill collections were installed** in both harnesses. In Codex a second, unrelated design skill was read alongside ours in most runs, because of routing instructions in that setup.
- One run per prompt. Answers were read for the failure modes in the table, not scored.

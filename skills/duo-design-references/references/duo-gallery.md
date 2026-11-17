# Reading Duo Gallery

Duo Gallery (https://duogallery.io/) is an independent catalog of iPhone apps captured by hand on an iPhone Duo. Facts below were read from the site on 2026-11-17; the site is the authority and will change.

## Status labels

The site checks each app on its own device and gives one of three answers:

| On the site | In its text catalog | Meaning | Reference? |
|---|---|---|---|
| Optimized | `optimized for iPhone Duo: yes` | Fills the inner display with a layout made for it | **Yes** |
| Partly optimized | `optimized for iPhone Duo: partial` | Fills most of it, or only some screens are adapted | No |
| Not optimized ("not yet") | `optimized for iPhone Duo: no` | The phone layout sits in the middle with empty space | No |

The page https://duogallery.io/optimized also has an "Apple's list" tab: apps that Apple lists as optimized and that the site has **not** checked itself. They are shown as optimized there. Do not use them as references until they appear among the hand-checked apps. The site notes that an app can carry Apple's "Made for iPhone Duo" badge and still come out only partly optimized in its own check.

On 2026-11-17 the hand-checked set was 104 apps: 53 optimized, 22 partly, 29 not. Do not rely on these numbers.

## States

Every screen page offers up to three states: **Closed** (outer display), **Partially folded** and **Open** (inner display), often in light and dark mode. Not every screen has all three. Many screens have no partially folded image, and many that have one show the same layout as open. The site marks those "Same as open". Only a handful of screens have a layout of their own for the fold, so do not expect the gallery to settle partially folded questions.

The site does not distinguish orientation, book versus laptop pose, or Split View.

## Ways to query, in order of preference

1. **Its MCP server**, if your environment already has it connected. It is free and read-only, and offers screen search, an app lookup that includes the optimization status, screen images, app and pattern lists, and device specs. This plugin does not install it; setup instructions are at https://duogallery.io/mcp-server.
2. **Its text catalog.** https://duogallery.io/llms.txt lists every app with its status in one line. https://duogallery.io/llms-full.txt has every screen with the states it has and the image URLs. Search the catalog for `optimized for iPhone Duo: yes`.
3. **Its pages.** `https://duogallery.io/apps/<slug>` for an app, with `?state=closed`, `?state=partially-folded` or `?state=open`; each screen has its own page.
4. If none of these can be reached, ask the person for the screen URLs. Do not answer from memory.

## Cautions

- Each app was captured once. Check the "checked" date and app version on its page; an app may have changed since.
- Trust the state label on the page over the image file name.
- The site's display measurements come from the simulator and from screenshots, not from Apple.
- The site asks that each screen's page be cited, and says the screenshots are shown for reference and belong to the apps' makers. It grants no licence to reuse them.

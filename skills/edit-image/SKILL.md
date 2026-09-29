---
description: Edit, restyle, or vary an EXISTING image file using OpenAI gpt-image-2 through the Codex CLI — change one thing and keep the rest, swap a background, recolor to a brand palette, add or fix text, or produce style-matched variants of a reference image. Use whenever the user points at an image file and asks to change, fix, restyle, clean up, or make a version of it.
---

# Edit an existing image (gpt-image-2 via Codex CLI)

Same wrapper as generation, plus `--ref` to attach the source image:

```bash
codex-imagegen "<what to change>" <output.png> --ref <source.png> [--size WxH]
```

The wrapper attaches the reference with `codex exec -i`, tells Codex to preserve
everything not mentioned, and prints the absolute path of the new file. **The
source file is never modified** — always write to a new path.

## Examples

```bash
# change one thing, keep the rest
codex-imagegen "change the sky to a sunset orange, keep the building and people identical" \
  ./out/hero-sunset.png --ref ./assets/hero.png

# recolor to a brand palette
codex-imagegen "recolor to a monochrome palette of #2563EB on white, keep the exact shapes" \
  ./out/icon-blue.png --ref ./assets/icon.png

# style-matched sibling asset
codex-imagegen "a settings gear icon in exactly the style of the reference: same stroke weight, same palette, same corner radius" \
  ./out/settings.png --ref ./assets/home.png
```

Up to four images in total. `--ref` marks an image to **edit**; `--style-ref`
marks one that is only a style reference. The wrapper numbers them for Codex
(edit targets first), so you don't need to explain which is which.

## Writing the change description

Be surgical. The model preserves what you don't mention, so name the change and
then name what must survive it:

- Good: *"replace the text on the sign with 'OPEN 24/7', keep the font style, lighting and every other element identical"*
- Bad: *"make it better"* — produces an unrelated image

For a series of edits, chain them one at a time (each output becomes the next
`--ref`) rather than stacking five changes into one prompt.

## Rules

1. **Never overwrite the source.** Write to a new file; offer to replace only after
   the user has seen the result. Note that Codex itself resists overwriting — the
   wrapper prints the path actually written, which may be a versioned sibling like
   `out-v2.png`. Use the printed path, not the one you asked for.
2. **Verify by viewing.** Read the output PNG with the Read tool and compare
   against the request before reporting done. Regenerate with a sharper prompt if
   the model drifted — at most 2 retries.
3. **Use a Bash timeout of at least 300000 ms** (5 minutes).
4. **For a transparent result**, add `--transparent` — the built-in tool keeps
   native alpha, and the wrapper warns if the PNG came back without it. Say
   "keep the transparent background" in the prompt when the source is already
   transparent.
5. **Not for precise pixel work.** Cropping, resizing, rotating, format conversion
   and compression are faster and lossless with ImageMagick or `sips` — use those
   directly instead of regenerating.
6. Each edit spends the user's ChatGPT plan quota. Don't loop unprompted.

For multi-image jobs, hand the whole brief to the `codex-artist` subagent instead.

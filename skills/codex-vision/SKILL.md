---
description: Have OpenAI Codex (latest GPT model) look at one or more images and answer about them — compare a UI screenshot against its design mock, check a generated image against its brief, read text or numbers off a chart or scan, or get an independent visual critique. Use when the user says "have codex look at this", "does the screenshot match the design", "second opinion on this image", or when a visual judgment matters enough to want two independent reads.
---

# Let Codex look at images

`codex-run` attaches images with `-i` (repeatable). Codex sees them alongside the
task and can also read the repo, so it can compare a screenshot with the code
that rendered it.

```bash
codex-run -i <image> [-i <image> ...] "<self-contained question>"
```

It prints only Codex's final answer and runs read-only by default.

## Examples

```bash
# screenshot vs design mock
codex-run -C /path/to/repo -i ./shots/login.png -i ./design/login-mock.png \
  "Image 1 is the implemented login screen, image 2 is the design mock. List every visible difference (spacing, colour, type, copy, alignment) as a bullet with the component it belongs to. Most important first."

# check a generated asset against its brief
codex-run -e low -i ./assets/og.png \
  "Brief: 'OG card, dark navy background, the words \"Ship faster\" in bold white sans-serif, logo bottom-left'. Does the image meet each point? Answer point by point, yes/no plus a short reason."

# extract data
codex-run -i ./chart.png "Read every bar value off this chart and return them as a markdown table."
```

## Rules

1. **You can see images too.** Use this for a genuinely independent second read,
   for multi-image comparisons you want done outside this context, or when the
   user asks for Codex. For a quick look at one image, just Read it yourself.
2. **Number the images in the prompt** ("image 1 is…, image 2 is…"), in the order
   you pass `-i`.
3. **Report Codex's answer as Codex's.** Verify concrete claims (a colour, a
   misaligned element) against the image yourself before acting on them.
4. Bash timeout ≥ 600000 ms. `-e low` is enough for simple look-and-describe
   questions and is much faster.
5. Each call spends the user's ChatGPT plan quota.

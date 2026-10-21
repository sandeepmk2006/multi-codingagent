---
description: Get an independent GitHub Copilot review of the current diff, then judge each finding.
argument-hint: "[<base-ref>] [--model <m>] [extra context]"
---
Run: `copilot-delegate --review $ARGUMENTS`
(If no base ref is given it reviews `git diff HEAD`. Pass a model different from the author's for a real second opinion.)

Then act as final judge: for each finding, check the code yourself and label it CONFIRMED (fix it or list it) or REJECTED (one-line reason). Do not apply findings blindly.

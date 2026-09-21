# Baselines

One directory per eval case, one per run, holding what phase 10 exported:

```
evals/baselines/
├── 1-dense-data/
│   └── 2026-09-11/
│       ├── screens/            copied from design/screens/
│       ├── tokens.json         copied from design/tokens.json
│       ├── design-direction.md the direction the run chose
│       └── audit.md            the audit report
├── 2-landing-page/
├── 3-mobile-onboarding/
└── 4-incremental/
```

After running a case (`evals/README.md`), copy those four things in. Before the
next behavior change, run the same case and put the two runs side by side:
the PNGs first — that is where "tuned to the last case" shows — then the
direction file (did the committed choice move?), then `tokens.json` (did the
inventory shrink?), then the audit (are the same criteria failing?).

Baselines are not a test suite and there is no pass threshold. They are the
previous case kept in view, which is the one thing the plugin's characteristic
failure needs. Delete runs older than the last two per case.

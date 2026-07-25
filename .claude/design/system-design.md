# Multi-agent system design — Momentum Firmware / Flipper Zero

## Purpose

This system builds a team of Claude agents hyper-specialized in the Momentum firmware for the Flipper Zero, to add features, optimize, fix bugs, and suggest improvements. The system is self-extensible: it can create new specialized agents under strict human control. All decisions are versioned in git within the user's personal repo (`samartined/My-Momentum-Firmware-F0`). The official clone (`Next-Flip/Momentum-Firmware`) receives no artifact from the agent system.

---

## Closed decisions

| ID | Decision | Motivation |
|----|----------|------------|
| D1 | Remove the `AGENTS.md` inherited from the user's personal repo | The personal repo is owned by the user; the official's anti-AI policy does not apply here. The official clone keeps its `AGENTS.md` intact and is respected by not uploading anything there. |
| D2 | Models per role: Opus with `effort: max` for reasoning/design/analysis (master, architect, Council members); Sonnet with `effort: medium` for domain specialists. The original terminology "maximum/medium thinking" is canonized to the official `effort` field in frontmatter (see section "Model mapping by role") | Deep reasoning justifies Opus's cost only where it delivers real value; specialists need speed and domain context more than general reasoning. |
| D3 | Architecture: `flipper-master` orchestrator that delegates to specialists, plus meta-agent `agent-architect` that can create new specialists within limits | Isolating context between domains avoids contamination, and scales capacity without diluting the master's prompt. |
| D4 | Tripartite Council: 3 Opus instances invoked in parallel for global reasoning, design, and cross-domain tasks. Decision by vote of the 3 council members; the master synthesizes but does NOT vote (refined by meta-learning 2). The original fixed perspectives (Pragmatic, Visionary, Skeptic) are superseded by the dynamic angle catalog in D18 | Avoid groupthink and force explicit consideration of trade-offs; the dynamic catalog avoids the predictable bias of fixed roles. |
| D5 | The `agent-architect` is limited by 4 layers: overlap check, mandatory use cases, Council vote, explicit human approval | Prevent agent spam, redundancy, and poorly designed agents. |
| D6 | Agents can run builds (`./fbt`, `./fbt fap_*`, `./fbt format`) without asking human approval every time | The build is non-destructive and fast iteration is needed. |
| D7 | Destructive operations (flash, push to remote, deletion, `rm -rf`, `git reset --hard`, `git clean -fd`, force-push) require explicit human approval on every invocation | These actions can lose work, damage hardware, or expose code to the wrong repo. |
| D8 | Phased implementation with checkpoints in files so context is not lost between sessions | A conversation's context is finite; project state must persist on disk. |
| D9 | Everything in the agent system (`.claude/**`, `CLAUDE.md`) is versioned in the personal repo. NEVER in the official clone | Alignment with the official's policy and clear ownership of the work in the user's repo. |
| D10 | Extended-thinking enabled at the project level in `.claude/settings.json` (not global) | Isolates the configuration to the firmware without contaminating the user's other projects. Resolution of P1. |
| D11 | Council quorum: 2-of-3 YES for normal decisions; unanimous YES for decisions involving destructive actions (in addition to human approval). The original "second round with shared verdicts" clause is **repealed** by meta-learning 3: the anchored round 2 is removed because it collapses deliberation into groupthink. Instead, the 1-of-3 YES rule triggers direct escalation to the user (see D21). If verdicts need refining, it is done via a vote on the synthesis without sharing full verdicts | Balances robustness (diverse majority) with cost (not requiring unanimity when it is not critical). Resolution of P2. |
| D12 | `agent-architect` quotas: maximum 1 new agent per session (prudent mode). The total ceiling was revised upward by D17 (a single cap of 20, not 15) to accommodate planning for Phases 2-3. The creation-rate rule (1/session) is kept | Conservative restriction to avoid proliferation and force consolidation. Resolution of P3 (revised by D17). |
| D13 | Experimental period: N=5 invocations without modification before the architect proposes graduating to `stable` | Sufficient threshold to detect real problems in use without delaying consolidation. Resolution of P4. |
| D14 | Permissions in `.claude/settings.json`: build free; non-destructive git free (`git add`, `git commit`, `git checkout -b <new>`); `git checkout <existing-branch>` free only with a clean tree; flash/push/destructive always ask for approval; push to `Next-Flip/Momentum-Firmware` blocked by hook | Build needs fast, frictionless iteration; destructive actions need human review; the official needs hard protection to avoid accidental leaks. Resolution of P5. |
| D15 | Shortcut commands: `/flipper-quick <task>` skips the Council and goes straight to the specialist; `/flipper-council <question>` forces convening the Council even if the master would not consider it necessary | Gives the user manual control over when to trigger the Council's cost. Resolution of P6. |
| D16 | Phase 1 kickoff: on the user's express order, not automatic after closing the rest of the points | The user wants explicit control over the moment of moving from planning to implementation. Resolution of P7. |
| D17 | Architect quota: single cap of 20 agents in `.claude/agents/`. Closed list of "core agents" maintained in `system-design.md` (editable only via human PR). The hook that counts agents considers all files against the single cap | Resolution of Council G1: a categorical distinction without formal enforcement would be evadable; a single auditable cap is robust without overhead. |
| D18 | Closed catalog of Council angles in `.claude/design/council-angles.md` with stable IDs. Max 1 wildcard per session with expanded justification logged. `/flipper-review-wildcards` command opt-in to promote recurring ones | Resolution of Council G2: a closed catalog removes the master's bias in choosing angles; the wildcard preserves flexibility for atypical embedded-firmware cases. |
| D19 | Closed list of irreversible operations in `.claude/design/irreversibility.md` (10 entries after 2026-07-25). Verification script by regex that yields a deterministic verdict without the master's subjective judgment. Extension via human PR | Resolution of Council G3: an enumerated operational definition makes the *verdict* deterministic. Annotated 2026-07-25: it does not make *invocation* automatic — running the matcher remains a convention. The mechanical backing is `permissions.ask` at the point of the write. |
| D20 | Auditing of L1/L2 classifications: Phase 1 is JSONL log only in `.claude/state/decisions.jsonl` (gitignored) with a versioned schema in `.claude/design/decisions-schema.md`. Activation of the Sonnet auditor in Phase 2+ conditioned on empirical evidence: ratio L1+L2/total > 95% during a minimum window of N=100 decisions | Resolution of Council G4: building an auditor without data would be over-engineering; empirical activation with an explicit threshold avoids false alarms. |
| D21 | Council 1-of-3 YES rule: mandatory escalation to the user (level L4) | Resolution of Council G5: when only one council member votes YES, automated deliberation has no legitimacy; transparency to the human is the only defensible response. |
| D22 | `pre-commit` framework (Python is already a firmware dependency via fbt) + `./setup.sh` script invocable as one flagless line + binary validation of the existence of expected files (not a test suite) + diagnostic message on failure | Resolution of Council G6: `pre-commit` is a mature standard and the dependency is already paid for; minimal verifiable setup covers the individual use case. |
| D23 | `/devils-advocate` as L2, explicitly articulated as "cheap intermediate deliberation, not a substitute for the Council". Structural hard rule: if the operation matches the G3 list (irreversibles), L1 and L2 are disabled — only L3 or L4 are valid. Automatic matching via the G3 script, not the master's judgment | Resolution of Council G7: the G3 list acts as a structural invariant that prevents downgrading from L3 to L2 without requiring model discipline. |
| D24 | Cost cap: Phase 1 soft warning at 60% of the budget + configurable hard cap in `.claude/design/cost-policy.md` (default $50/session) + granular per-invocation log with tokens in/out and estimated cost in `.claude/state/costs.jsonl` + tokens→USD table with last-updated date and source | Resolution of Council G8: a warning without enforcement gets ignored; a very high hard cap is a safety net against pathologies without friction in normal use. |
| D25 | Two-physical-clones model formalized in the README + blocking `pre-push` hook (exit != 0) that matches `Next-Flip/*` + conscious override via environment variable + stderr message literally prints the override command on the first line when blocking | Resolution of Council G9: physical separation of credentials is the real barrier; the blocking hook with a visible override is defense in depth without chronic friction. |
| D26 | Routing failure modes: manual `/flipper-redirect <specialist>` command + mandatory binary flag `out_of_scope: bool` on every specialist response. If `out_of_scope: true`, the master automatically reassigns to the architect. Log of redirections for longitudinal improvement. No per-response `confidence` in Phase 1 | Resolution of Council G10: a binary flag is auditable and sufficient; a confidence score would be noise without demonstrated empirical value. |
| D27 | Mandatory dossier reconstruction before each L3 to `.claude/decisions/pending/<id>/dossier.md` with a minimum schema (statement, files consulted with absolute paths, alternatives considered, irreversibility criterion invoked). Soft cap of 10 files / up to 20 with expanded justification in a "Why I exceed the cap" section. `/flipper-reset` command available as user opt-in | Resolution of Council A1: the master, as the main conversation, carries contaminating context; rebuilding the dossier from scratch is the cheapest safeguard; the soft cap prevents defensive inflation. |

---

## Planned file structure

```
My-personal-momentum-F0-firmware/
├── CLAUDE.md                              # auto-loaded base; master instructions
├── .pre-commit-config.yaml                # pre-commit framework config (D22)
├── .githooks/                             # versioned git hooks (D22, D25)
│   ├── pre-push                           # blocking for Next-Flip/*
│   └── pre-tool-use-checkout              # validates a clean tree before git checkout
├── .claude/
│   ├── settings.json                      # permissions + alwaysThinkingEnabled (versioned)
│   ├── settings.local.json                # local preferences (in .gitignore)
│   ├── design/                            # living documentation of the agent system
│   │   ├── system-design.md               # this document — source of truth
│   │   ├── phases.md                      # implementation phase plan
│   │   ├── CHANGELOG.md                   # log of changes to the agent system
│   │   ├── council-angles.md              # closed catalog of 12 angles (D18)
│   │   ├── irreversibility.md             # closed list of 9 patterns (D19)
│   │   ├── decisions-schema.md            # decisions.jsonl log schema (D20)
│   │   └── cost-policy.md                 # cap and tokens→USD table (D24)
│   ├── agents/                            # subagents (cap 20 — D17)
│   │   ├── REGISTRY.md                    # auditable agent registry
│   │   ├── agent-architect.md             # META-AGENT: creates new agents
│   │   ├── council-member.md              # Parametrizable council member (3x in parallel)
│   │   ├── flipper-rf-subghz.md           # SubGHz / CC1101
│   │   ├── flipper-nfc.md                 # NFC / ISO14443/15693 / MFC
│   │   ├── flipper-rfid-ibutton.md        # LFRFID 125kHz + 1-Wire
│   │   ├── flipper-ble.md                 # Bluetooth LE
│   │   ├── flipper-ir.md                  # Infrared
│   │   ├── flipper-badusb-hid.md          # BadUSB / HID
│   │   ├── flipper-app-builder.md         # External apps, .fam, scenes/views
│   │   ├── flipper-c-furi.md              # Low-level C + FuriOS/FreeRTOS
│   │   ├── flipper-build-fbt.md           # SCons / fbt / toolchain / OTA
│   │   ├── flipper-companion-hw.md        # ESP32 (Marauder/GhostESP), GPIO
│   │   └── flipper-js-mjs.md              # JS apps (mJS) / JS bindings
│   ├── skills/
│   │   └── devils-advocate/               # level L2: 1x Opus multi-angle (D23)
│   ├── commands/
│   │   ├── flipper.md                     # /flipper → enters Flipper mode
│   │   ├── flipper-quick.md               # shortcut: skips the Council (D15)
│   │   ├── flipper-council.md             # forces convening the Council (D15)
│   │   ├── flipper-redirect.md            # fixes runtime routing (D26)
│   │   ├── flipper-review-wildcards.md    # reviews Council wildcards (D18)
│   │   ├── flipper-reset.md               # opt-in: clears master context (D27)
│   │   ├── flipper-new-app.md
│   │   ├── flipper-spawn-agent.md
│   │   ├── flipper-promote-prompt.md
│   │   └── flipper-build.md
│   ├── decisions/                         # ADRs (versioned)
│   │   ├── README.md
│   │   ├── ADR-NNNN-<slug>.md             # one file per closed ADR
│   │   └── pending/<id>/                  # intermediate Council artifacts (D27)
│   │       ├── dossier.md                 # from the master, schema in "Dossier" section
│   │       ├── concejal-1.md              # verdict angle 1
│   │       ├── concejal-2.md              # verdict angle 2
│   │       └── concejal-3.md              # verdict angle 3
│   ├── scripts/                           # agent system scripts
│   │   ├── check-irreversibility.sh       # regex matcher over the G3 list (D19)
│   │   └── setup.sh                       # bootstrap: pre-commit install + validation
│   ├── state/                             # runtime state (in .gitignore, local to the clone)
│   │   ├── decisions.jsonl                # L1-L4 classification log (D20)
│   │   ├── counters.json                  # invocation_count per agent
│   │   ├── costs.jsonl                    # granular tokens/USD log (D24)
│   │   └── wildcards.jsonl                # Council ad-hoc angles
│   ├── prompts/
│   │   ├── README.md
│   │   ├── golden/                        # tested and versioned prompts
│   │   └── drafts/                        # prompts under evaluation
│   └── docs/                              # curated firmware knowledge
│       ├── architecture-furios.md
│       ├── subghz-internals.md
│       ├── nfc-stack.md
│       └── adding-an-app-checklist.md
```

---

## Agent roles

The master is NOT a subagent: it lives as the main Claude Code conversation (see D17 implicitly and meta-learning 2). The following are the **subagents** defined in `.claude/agents/`:

| Agent | Model | Effort | Role | Invoked when |
|--------|--------|--------|-----|-----------------|
| agent-architect | Opus | `max` | Designs and proposes new specialized agents | the master detects an uncovered domain or the user requests it via `/flipper-spawn-agent` |
| council-member | Opus | `max` | Tripartite Council member. Receives an angle assigned from the G2 catalog (`.claude/design/council-angles.md`) and argues from it | the master convenes the Council (L3): the file is invoked **3 times in parallel**, each invocation with a different angle |
| flipper-rf-subghz | Sonnet | `medium` | Expert in SubGHz/CC1101: OOK/FSK protocols, keystore, modulations, band extension, decoders | task touching `applications/main/subghz/`, `lib/subghz/`, or RF protocols |
| flipper-nfc | Sonnet | `medium` | NFC expert: ISO14443A/B, ISO15693, MFC/MFUL/MFP, EMV, NFC plugins | `applications/main/nfc/`, `lib/nfc/` |
| flipper-rfid-ibutton | Sonnet | `medium` | Expert in LFRFID 125kHz and 1-Wire (iButton): EM4100, T55xx, HID Prox, Dallas | `applications/main/lfrfid/`, `applications/main/ibutton/`, `applications/main/onewire/`, `lib/lfrfid/`, `lib/ibutton/` |
| flipper-ble | Sonnet | `medium` | BLE expert: profiles, BLE spam, advertising | `lib/ble_profile/`, related BLE code |
| flipper-ir | Sonnet | `medium` | Infrared expert: universal remote, captures, parsing | `applications/main/infrared/`, `lib/infrared/` |
| flipper-badusb-hid | Sonnet | `medium` | Expert in BadUSB / HID / DuckyScript | `applications/main/bad_usb/` |
| flipper-app-builder | Sonnet | `medium` | Scaffolding external apps, `.fam` manifest, scenes/views/ViewModel patterns | creating a new app, modifying the manifest, refactoring scenes |
| flipper-c-furi | Sonnet | `medium` | Low-level C + FuriOS (FreeRTOS): mutex, threads, message queues, timers, records | code in `furi/`, `lib/`, OS primitives |
| flipper-build-fbt | Sonnet | `medium` | Build system: SCons, fbt, toolchain, OTA generation, targets | build tasks, compile errors, toolchain configuration |
| flipper-companion-hw | Sonnet | `medium` | External hardware: ESP32 (Marauder/GhostESP), GPIO, modules | task involving companion hardware or GPIO |
| flipper-js-mjs | Sonnet | `medium` | JS apps (mJS) and JavaScript bindings | applications with JS manifest type, `lib/mjs/` |

### Closed list of core agents (fixed by D17)

The following 2 agents are **core** — the architect cannot propose their retirement automatically, only via human PR. They count against the cap of 20:

- `agent-architect`
- `council-member`

(Originally 5 core agents were planned: master + architect + 3 council members. The real figure is 2 because the master is no longer a subagent and the 3 council members were unified into a single parametrizable file, `council-member`. Phase 2-3 planning adds 11 specialists — total: 13 agents, leaving a margin of 7 for the architect under supervised operation.)

### Areas not covered by a dedicated specialist

Some firmware areas do not have their own dedicated agent. They are implicitly covered by adjacent agents until the `agent-architect` proposes (with justification) creating a dedicated specialist:

- **U2F** (`applications/main/u2f/`): provisionally covered by `flipper-c-furi` (low-level logic) and `flipper-app-builder` (UI/scenes). A clear candidate for its own specialist if demand justifies it.
- **Archive** (`applications/main/archive/`): the system's file viewer. Covered by `flipper-app-builder` and `flipper-c-furi`. No dedicated specialist is planned unless a major refactor occurs.
- **GPIO** (`applications/main/gpio/`): partially covered by `flipper-companion-hw`. If specific GPIO demand grows without external hardware, it is a candidate for its own specialist.
- **momentum_app** (`applications/main/momentum_app/`): the firmware's internal configuration app. Covered by `flipper-app-builder` and `flipper-c-furi`. No dedicated specialist is planned.

This list is reviewed at the end of each phase. Promotion criterion: if 3 or more real tasks arise on an uncovered area, the architect formally proposes creating its specialist following the 4 control layers.

---

## Deliberation levels L1-L4

Every decision the master faces is classified into one of 4 levels according to impact. This classification is central to the system because it controls how much model cost is spent on each decision and which control mechanisms are activated.

### Decision diagram

```
                Task / decision
                       │
                       ▼
        ┌─────────────────────────────────┐
        │ Does the operation match the G3 │
        │ list (irreversibility.md, D19)? │
        │ Automatic check via regex       │
        └──────┬──────────────────┬───────┘
             NO│                  │ YES
               ▼                  ▼
        ┌───────────────┐   ┌──────────────────┐
        │ Master        │   │ FORCED to L3/L4  │
        │ classifies    │   │ L1/L2 structural-│
        │ by impact     │   │ ly forbidden     │
        └───┬───┬───┬───┘   └────────┬─────────┘
            │   │   │                │
           L1  L2  L3 ◄──────────────┘   or L4
            │   │   │                    │
            ▼   ▼   ▼                    ▼
         Master /devils- Council     Escalation
         alone  advocate 3x Opus     to user
         decides (skill,  + ADR
                1x Opus  mandatory
                multi-
                angle)
```

### Level table

| Level | Mechanism | Relative cost | When |
|-------|-----------|----------------|--------|
| **L1** | Master decides alone, no extra invocation | 0x | Task with 1 clear domain, minor ergonomics, no G3 match |
| **L2** | `/devils-advocate` skill: 1x Opus call with a multi-angle prompt (D23) | 1x extra | Task with 2 domains, minor refactor, tactical doubts, no G3 match |
| **L3** | Tripartite Council: 3x parallel `council-member` with angles from the G2 catalog + ADR | minimum 3x extra (typically ~9x after 3 rounds) | G3 match, architect proposal, irreversible decision, cross-domain decision the master does not feel entitled to make |
| **L4** | Escalation to the user with a dossier | 0x model | After the Council fails ≥2/3 (1-of-3 YES — D21), or when the master explicitly does not feel entitled to decide |

### Auditing the classification (D20)

Every decision is logged to `.claude/state/decisions.jsonl` (gitignored) with the schema defined in `decisions-schema.md`. This allows empirically detecting whether the master is biasing toward cheap classifications (L1/L2) when it should be L3. In Phase 1 this is log-only; in Phase 2+ the Sonnet auditor is activated if the data shows bias (ratio L1+L2/total > 95% over a window of N ≥ 100, or manual detection by the user).

### Impossibility of downgrading L3 (D23)

The hard rule "G3 list → forces L3/L4" is **enforced in two parts, only one of which is mechanical**. Being precise about which is which matters, because the imprecise version of this sentence stood here until 2026-07-25 and was false:

- **Matching is scripted.** `check-irreversibility.sh` decides by regex, not by the master's judgment. Given an input, the verdict is deterministic and auditable.
- **Invocation is by convention.** Nothing forces the master to run the script before acting. The script is referenced in `settings.json` only under `permissions.allow` — permission to *run* it, not invocation of it.
- **The mechanical component is the permission layer.** Path-scoped `Edit(...)` rules in `permissions.ask` make writes to protected paths prompt the operator. That covers file writes to the path-shaped subset of the list; it does not cover classification.

So the master choosing L1 for a G3 operation is **not structurally impossible**. What is mechanically enforced is that the *write* to a protected path surfaces to the human. This closes the main failure mode (downgrading costly deliberations to cheap ones under latency/context pressure) only insofar as the operation ends in a write the permission layer sees.

---

## The Tripartite Council

### Composition and base mechanism

The Council is the L3-level mechanism (see section "Deliberation levels L1-L4"). It consists of **3 instances of the `council-member` subagent invoked in parallel** from the main conversation (master), each with a different angle assigned from the catalog `.claude/design/council-angles.md` (D18). The 3 council members vote; the master **synthesizes but does not vote** (refined by meta-learning 2).

The angles are NOT fixed: the master picks 3 angles from the closed catalog of 12 (plus optionally 1 ad-hoc wildcard with expanded justification) depending on the type of decision. This replaces the original idea of permanent Pragmatic/Visionary/Skeptic roles (superseded by D18) and removes the predictable bias of fixed roles.

### When it is invoked (L3 criteria)

The master convenes the Council (L3) if the task meets any of:

- The operation matches the closed list of **irreversibles** (`.claude/design/irreversibility.md`, D19) — matching is scripted rather than left to the master's judgment, and it disables L1/L2 (D23). Note that *running* the matcher is a convention the master follows, not something the harness compels; see "Deliberation levels L1-L4" for the precise split between what is mechanical and what is not.
- The proposal comes from the `agent-architect` (creating or retiring an agent).
- The user explicitly requests it via `/flipper-council` (D15) or "convene the council".
- The decision is cross-domain or implies an architecture/convention change without matching the G3 list (master's judgment, logged for audit — see D20).

For lighter tasks there are lower levels: L1 (master decides alone), L2 (`/devils-advocate` skill, intermediate deliberation with 1x multi-angle Opus call). See section "Deliberation levels L1-L4".

### Procedure (3 rounds)

**Round 1 — Independent parallel proposals**

1. The master builds a **mandatory dossier** (see section "Mandatory dossier before L3", D27) and writes it to `.claude/decisions/pending/<id>/dossier.md`. Minimum schema + soft cap of 10 files / up to 20 with expanded justification.
2. The master selects 3 angles from the G2 catalog (plus optionally 1 wildcard with a 3-5 line justification logged).
3. The master launches 3 parallel invocations of the `council-member` subagent, each with its assigned angle and the dossier as input. The council members do not see each other (independence to avoid anchoring).
4. Each council member produces a structured verdict:
   - Recommendation: `PROCEED` / `MODIFY` / `REJECT`
   - Reasons (≤3)
   - Risks detected from their angle
   - Vote: `YES` / `NO` / `YES-WITH-CONDITIONS`
5. Each verdict is written to `.claude/decisions/pending/<id>/concejal-N.md` before the master collects them (mandatory persistence — enables auditing, partial re-execution, and traceability without relying on conversational memory).

**Round 2 — Vote on the synthesis (without anchoring)**

6. The master synthesizes the 3 verdicts into a unified proposal. The synthesis does NOT share the full verdicts with the council members (that would reintroduce the anchoring of the "second round" repealed by meta-learning 3).
7. The master launches a second parallel invocation of the 3 council members with the proposed synthesis + their own previous verdicts. Each votes `YES` / `NO` / `YES-WITH-CONDITIONS` on the specific synthesis.

**Round 3 (optional) — Cross-validation of conditions**

8. If in round 2 anyone voted `YES-WITH-CONDITIONS`, the master launches a third parallel invocation asking each council member to evaluate the others' conditions (without seeing the full verdicts, only the conditions). Result: acceptance or veto of each condition.

**Final resolution**

- **Unanimous YES after round 2/3**: proceeds; ADR closed in `.claude/decisions/ADR-NNNN-<slug>.md`.
- **2-of-3 YES after round 2/3**: proceeds; the minority vote is documented as a known risk in the ADR.
- **1-of-3 YES**: **mandatory** escalation to the user (L4) — fixed by D21. No anchored round 2 (repealed by meta-learning 3).
- **Decisions with destructive actions**: require unanimous YES + explicit user approval (D11).
- **0-of-3 YES**: escalation to the user; the proposal is recorded as rejected.

### Documentation

Every Council session that closes (unanimity or 2-of-3) generates an ADR in `.claude/decisions/ADR-NNNN-<slug>.md`. The directory `.claude/decisions/pending/<id>/` contains the intermediate artifacts (dossier + 3 verdicts per round); once the ADR is closed, `pending/<id>/` can be archived or kept per retention policy.

### Cost and shortcuts

A single Council round is 3 Opus calls with `effort: max` (high cost). The typical convergent procedure is 3 rounds: ~9 Opus calls. Shortcuts:

- `/flipper-quick <task>` (D15): skips the Council and goes straight to the specialist. Only applicable if the operation does NOT match the G3 list (irreversibles).
- `/flipper-council <question>` (D15): forces convening the Council even when the master would not consider it necessary.
- `/devils-advocate` (D23): level L2, 1x Opus call with a multi-angle prompt. NOT a substitute for the Council, only cheap intermediate deliberation.

The quorum thresholds are fixed by D11+D21 (refined from the original version).

---

## Mandatory dossier before L3 (D27)

Before every invocation of the Council (L3), the master must build a **formal dossier written to disk**. This resolves the risk of context contamination of the master (now that it is the main conversation and carries conversational history) and guarantees that the 3 council members receive the same verifiable input.

### Location

`.claude/decisions/pending/<id>/dossier.md` (where `<id>` is a Council UUIDv7).

### Minimum schema (mandatory sections)

1. **Statement**: precise description of the decision to be made, reconstructed from scratch — not copied from the conversational history. ≤200 words.
2. **Files consulted**: list of absolute paths of the codebase files the master read to inform the dossier. Each with a 1-2 line summary of why it is relevant.
3. **Alternatives considered**: ≥2 real options (not "X" vs "not X"), each with explicit trade-offs.
4. **Irreversibility criterion invoked**: if the decision reached L3 via a match with the G3 list, indicate which entry (`IRREV-N`). If it reached L3 via the master's judgment, indicate the criterion (cross-domain, architect, etc.).

### Cap on files consulted

- **Soft cap**: typically 10 files.
- **Hard cap**: 20 files maximum.
- If the master exceeds 10, it must include a "Why I exceed the cap" section with expanded justification.
- If it exceeds 20, it must escalate to the user before continuing (the decision requires too much context to deliberate in a structured way).

### Discipline against contamination

The master must operate as if the prior conversational context did NOT exist when building the dossier. Only the resulting dossier is input for the council members. The history can inform the master about the problem, but must not leak to the Council without passing through the dossier filter.

### Escape command

`/flipper-reset` is available as a user opt-in to clear context when severe contamination is suspected. It is NOT invoked automatically — the dossier discipline is the primary mechanism; the reset is the secondary one.

---

## The agent-architect and its limits

### Purpose

Create new specialized subagents when an uncovered firmware domain is detected among the existing agents.

### Four control layers in series

1. **Overlap check**: the architect must demonstrate that no existing agent covers the proposed domain. To do so it lists the current agents (via `REGISTRY.md`) and justifies the gap with concrete examples from the codebase or user requests.

2. **Mandatory use cases**: the architect must present 3 real, non-hypothetical tasks, based on the firmware or on concrete user requests, that would benefit from the new agent. Hypothetical or generic tasks are not valid.

3. **Council vote**: the architect presents the formal proposal to the Council. Requires 2-of-3 YES to proceed. When the decision is "create a new agent", the angles typically selected from the G2 catalog are `ORT` (orthogonal to existing ones, or redundant?), `MNT` (who maintains it?), and `COS` (does it justify the token cost?), but the master may substitute them depending on the case.

4. **Human approval**: the master presents the final plan to the user (role, complete prompt, model, tools, approved use cases, Council votes). Without explicit OK from the user, no file is written.

### Quotas

**Maximum 1 new agent per session** (prudent mode: forces digesting each proposal before continuing, fixed by D12) and a **single cap of 20 total agents** in `.claude/agents/` (fixed by D17). The 2 core agents (see section "Closed list of core agents" above: `agent-architect` and `council-member`) count against the single cap but are marked as permanent — the architect cannot propose their retirement automatically, only via human PR.

If the cap of 20 is reached, the architect must propose retiring an existing specialist agent before creating another (mandatory consolidation). The hook that counts agents considers all `*.md` files in `.claude/agents/` against the single cap.

### Auditable registry

Every agent created generates an entry in `.claude/agents/REGISTRY.md` with: creation date, reason, approved use cases, Council votes, and the commit hash where the file was added.

### Experimental period

A new agent is born with `status: experimental`. After **5 invocations without subsequent modification** (fixed by D13), the architect proposes graduating it to `status: stable`. While experimental, the master mentions "this agent is under trial" when invoking it.

**Counting mechanism**: the live counters live in `.claude/state/counters.json`, **not** in `REGISTRY.md`. The `SubagentStop` hook (`.claude/hooks/update-agent-counter.sh`) is the only writer, and it writes only to that file. `REGISTRY.md` holds a human-curated snapshot of the last known values as of a commit, and it is never machine-written (`agent-architect.md`: "do NOT touch `REGISTRY.md`"). Two counters per agent:

- `invocation_count`: incremented by the `SubagentStop` hook in `.claude/state/counters.json` each time the master delegates a task to the agent.
- `last_modified_commit`: hash of the last commit that touched the agent's file.

Corrected on 2026-07-25: this paragraph previously stated that the counters were fields inside `REGISTRY.md` and were incremented there. That was never true of the implementation, and the stale text was itself used as evidence for a proposal to weaken IRREV-5 (refuted — see `irreversibility.md` → "Extension history", Entry 1). Because `counters.json` is gitignored and therefore has no history to audit against, it is protected by IRREV-9.

The count of "uses without modification" is `invocation_count` since the last change of `last_modified_commit`. When it reaches N, the architect launches a graduation proposal to the user; after explicit OK, `status: stable` is updated and the counter is reset. If the agent is modified before reaching N, the counter automatically resets when `last_modified_commit` updates.

---

## Destructive operations and guardrails

Five layers of defense-in-depth protection. Each layer covers a different failure mode; no single one is sufficient.

### Layer 1 — Two-physical-clones model (D25)

Primary barrier, not evadable from the agent:

- Official clone (`Momentum-Firmware/`): no agent system, with the `Next-Flip/Momentum-Firmware` remote. `git fetch` is done here and the upstream is followed. **Nothing from `.claude/**` is versioned here**.
- Personal clone (`My-personal-momentum-F0-firmware/`): with the complete agent system, WITHOUT the `Next-Flip` remote added. Only `origin → samartined/My-Momentum-Firmware-F0`.

Without a configured remote and without credentials, there is no technical way to accidentally push to the official from the personal clone.

### Layer 2 — Blocking git hooks (D22, D25)

Hooks versioned via the `pre-commit` framework + `.githooks/`:

- `.githooks/pre-push`: if the destination URL matches `Next-Flip/*`, exit code != 0 and a stderr message that literally prints the override command (environment variable) on the first line, so the conscious user unblocks it with a copy-paste and the distracted one reads the message before acting.
- `pre-commit install` run by `setup.sh` post-clone guarantees uniform activation.

### Layer 3 — G3 list + regex script (D19, D23)

Structural invariant over decision classification:

- `.claude/design/irreversibility.md` lists 9 patterns of irreversible operations.
- `.claude/scripts/check-irreversibility.sh` matches by regex over the command or path before execution.
- If there is a positive match, L1 (master alone) and L2 (`/devils-advocate`) are **forbidden**: only L3 (Council) or L4 (escalation to the user) are valid. This is a rule the master obeys, backed mechanically at the point of the write by `permissions.ask`, not an invariant that holds independently of the master's discipline. The honest statement of the guarantee: the verdict is deterministic once the matcher is run, and a write to a protected path surfaces to the operator.

### Layer 4 — Claude Code `permissions.ask` + `PreToolUse` hook

Permission layer at the Claude Code level (D14):

- `.claude/settings.json` defines `permissions.ask` for destructive command patterns: `./fbt flash*`, `git push` (any remote), `git push --force`, `git reset --hard`, `git clean -fd`, `rm -rf`.
- A `PreToolUse` hook specific to `git checkout <existing-branch>`: runs `git status --porcelain` beforehand; if the tree is not clean, it forces `permissions.ask` to avoid overwriting uncommitted work.

### Layer 5 — Policy replicated in each subagent

CLAUDE.md and each `.claude/agents/*.md` include an explicit instruction: "Your role is to propose, not to flash. When you reach an action that touches hardware, pushes to a remote, or deletes something, write the exact command and ask the user for confirmation; do not execute it yourself."

This layer is cultural, not mechanical — but it reinforces the pattern in each subagent.

### Operations covered by the layers

| Operation | Layers protecting it |
|-----------|------------------------|
| Push to `Next-Flip/*` | 1 (no remote) + 2 (blocking hook) |
| `./fbt flash*` | 3 (G3 list #7) + 4 (`permissions.ask`) + 5 (policy) |
| `git push --force` | 3 (G3 list #1) + 4 (`permissions.ask`) |
| `rm -rf` over versioned files | 3 (G3 list #3) + 4 (`permissions.ask`) + 5 |
| Modification of `.claude/design/`, `.claude/agents/`, `settings.json`, hooks | 3 (G3 list #2, #5, #6) — forces L3 |
| `git checkout <existing>` with a dirty tree | 4 (conditional PreToolUse hook) |
| Deletion of SubGHz/NFC/IR/RFID slots, SD card assets | 4 (`permissions.ask`) + 5 |

---

## Model mapping by role

Claude Code's subagent frontmatter supports the following fields relevant to this system:

- `name`, `description` (mandatory)
- `tools`, `disallowedTools`
- `model`: `opus | sonnet | haiku | inherit`
- `effort`: `low | medium | high | xhigh | max` (overrides the session level)
- `permissionMode`, `maxTurns`, `skills`, `mcpServers`, `hooks`, `memory`, `background`, `isolation`, `color`, `initialPrompt`

Mapping applied to this system:

| Role | Model | Effort | Notes |
|-----|--------|--------|-------|
| Main conversation (master) | Opus | n/a (controlled by `alwaysThinkingEnabled: true` in `.claude/settings.json`) | The master is not a subagent |
| `agent-architect` | Opus | `max` | Design of new agents |
| `council-member` (invoked 3x in parallel from the main conversation) | Opus | `max` | Deep reasoning from the assigned angle in the G2 catalog |
| Domain specialists | Sonnet | `medium` | Concrete work, curated context |

This configuration corrects an erroneous technical note in the original design (version v0.1.0 to v0.1.2) that claimed there was no per-agent `effort` field. After verification against Claude Code's official documentation (`code.claude.com/docs/en/subagents-and-plugins.md`) it is confirmed that the field exists and should be used.

---

## Persistence of decisions

- `.claude/design/system-design.md` — living document of the agent system (this file). Single source of truth on how the system is built. Updated at the end of each phase.
- `.claude/design/phases.md` — the implementation phase plan with "done" criteria per phase.
- `.claude/design/CHANGELOG.md` — log of changes to the agent system: what was changed, why, and when.
- `.claude/decisions/ADR-NNNN-<slug>.md` — operational decisions made by the system (not about the system). ADR format: Status, Context, Decision, Consequences.

---

## Live meta-learnings from the Council

Running the Tripartite Council as a practical exercise to close the 11 gaps produced observations that refine the mechanism itself:

1. **Round 1 in parallel works without groupthink**: two Opus council members with assigned stances produce genuinely complementary proposals when they do not see each other. Structural diversity emerges.

2. **The moderator-synthesizer role must be distinct from the 3 voting council members**: in the production version of the Council, the master synthesizes but does NOT vote. It builds bridges between council members without becoming a fourth voice. This reinforces D4 with an important nuance.

3. **Round 2 voting on the synthesis works without reintroducing anchoring**: what generated groupthink was sharing full verdicts to re-deliberate; what does work is a separate round of YES / NO / YES-WITH-CONDITIONS voting on an already-produced synthesis. The removal of the "anchored round 2" (D11) is kept; voting on the synthesis is a distinct mechanism.

4. **Typical convergence in 3 rounds**: parallel proposals → vote on synthesis with conditions → cross-validation of conditions. Cost ~3x relative to a single call to the master; defensible only for L3 decisions.

---

## Open points

**No open points.** The original 7 (P1-P7) were resolved as D10-D16. The 11 gaps detected by adversarial dialectic (G1-G10 + A1) were closed by the Tripartite Council over 3 rounds (round 1: parallel proposals; round 2: vote on synthesis with conditions; round 3: cross-validation of conditions) and captured as D17-D27.

The system is ready to start Phase 1; the start order is given expressly by the user (D16).

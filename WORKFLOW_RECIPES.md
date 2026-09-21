# Agent workflow framework & example recipes

Reference for building reliable **human + agent** development workflows.

## What you practiced

| Lab | Recipes in class |
|-----|------------------|
| **Lab 2** (wine / local agent) | **1** (`scripts/check.sh` shipped), **2** (`AGENTS.md` + pytest), **3** (create `/commit-code` in class) |
| **Lab 3** (sales pipeline / Cloud) | **2** (Part 2), **1** + **5** (Part 3: create `check.sh` + PR Automation) |

Recipes **4** and **6** are post-lab. Recipe **3** is in-class in Lab 2 and examples-only in Lab 3. Each lab’s [`examples/`](examples/) folder is **starter material** for that repo—the two trees are not the same. See [`examples/README.md`](examples/README.md).

---

## Core framework

**Treat agents like engineers with tools—not like the entire pipeline.**

| Principle | What it means |
|-----------|----------------|
| **Agents run scripts; they don't replace them** | Put linters, tests, and checks in deterministic scripts or CI. The agent's job is to run them and react to output. |
| **Agents are probabilistic; gates are deterministic** | Don't ask an agent "is this correct?" when `pytest` or `ruff` can answer definitively. |
| **ReAct loop** | **Reason** (decide what next) → **Act** (edit, run tool) → **Observe** (output) → repeat. Modern **agent harnesses** (Cursor, Claude Code, etc.) orchestrate much of this for you—you rarely build the loop yourself. See [Harness vs team workflow](#harness-vs-team-workflow) below. |
| **Escalating cost** | Cheap linters → tests → **fresh-context final review (expensive)** → **human merge**. Run the cheapest gate that can fail first. |
| **Separate implementer from final reviewer** | Just as a colleague with fresh eyes catches what you missed, an agent benefits when **another agent with fresh context** reviews the finished diff—not the same run that wrote the code. Humans and agents both review and iterate **while** building (editing, running tests, fixing); this principle is about the **final** critique before merge: sub-agent, PR Automation, Bugbot, Approval Agents, or human PR review. Fresh-context review costs extra time and model usage; use it last among automated gates, or skip with `--quick` while adopting. |
| **Humans keep merge authority** | Automate the inner loop; a person still approves the PR. |

### Harness vs team workflow

Modern coding agents are **model + harness**: the product wires tools, prompts, and orchestration. You experience much of the “agentic” behavior through that harness—not by implementing ReAct yourself.

**What the harness often does for you** (you’ll see these called out in the UI while the agent runs—e.g. “Planning…”, tool names, subagent launches):

| Harness step | What you may see | Examples |
|--------------|------------------|----------|
| **Planning** | An explicit plan or todo list before edits | Cursor Plan mode; Claude Code plan subagent; frontier models (e.g. Claude Fable) on long tasks |
| **Explore** | Search/read codebase, gather context | Built-in explore subagents, grep, semantic search |
| **Act** | Edit files, run terminal, call APIs | Write, Bash, MCP tools |
| **Observe** | Read test output, linter errors, command stdout | Agent reacts to tool results in the same session |
| **Delegate** | Spin up subagents with fresh context | Cursor Task/explore/bash; Claude Code subagents |
| **Reflect** | Self-check or revise before finishing | Increasingly built in; not a substitute for separate final review |

Products differ—Cursor, Claude Code, Copilot, and others expose different steps—but **planning** in particular is now explicit in many UIs. When you watch an agent “think,” you are often seeing the harness walk through these phases.

**What teams still wire explicitly** (what these labs and recipes focus on):

| Team layer | Why it still matters |
|------------|---------------------|
| **`AGENTS.md`, rules, prompts** | Repo policy and definition of done—the harness won’t infer your team’s standards |
| **Deterministic gates** (pytest, CI, linters) | Agents don’t always run checks reliably without encoding them; CI catches slips |
| **PR handoffs** (draft → ready, Automations) | Accountability and event-driven review on **your** process |
| **Fresh-context final review** | Bugbot, Approval Agents, PR Automations, human merge—separate from in-session self-check |

```text
Harness (product):     plan → explore → edit/run tools → observe → (delegate | reflect) → …
Team workflow (you):   AGENTS.md + gates + draft PR + final reviewer + human merge
```

You usually **don’t** build the inner tool loop. You **do** design reliability and accountability around probabilistic agents.

### Intentional gates—not the only way

The recipes below are **one adoption path**, not a mandatory stack. Teams pick surfaces that match their maturity: pytest in `AGENTS.md` only, or check scripts, or CI, or PR Automations—or combinations. The **core idea** this course is teaching:

1. **Implementation agent** does the work (Cloud Agent, local agent, etc.).
2. **Deterministic gates** (linters, tests, CI) catch objective failures cheaply.
3. **Fresh-context final review** critiques the diff before merge—another agent (or reviewer), not the one that wrote the code. Incremental self-review while implementing is expected; this step is the deliberate **final** pass.

That third step is the main payoff of Recipe 5 and the `/commit-code` sub-agent step in Recipe 3. Research and practice show that a **reflection** or **critique** pass—stepping back from the implementation trace—often improves quality. You are wiring that into the workflow on purpose.

**How this relates to ReAct and the harness:** The harness runs the **inner** tool loop (reason → act → observe, often with subagents). Recipe 2 (`AGENTS.md` + pytest) and Recipe 4 (CI) add **team gates** on top—because harness defaults ≠ your definition of done. **Fresh-context final review** is a **second loop** after implementation: the reviewer observes the finished diff (and optionally CI status) without the implementer’s chain-of-thought. It complements in-session reflection; it does not replace pytest. See [Harness vs team workflow](#harness-vs-team-workflow).

You can place the reflection step locally (slash command sub-agent), before the PR (Cloud Agent golden prompt—Lab 3 Part 3 Step 9), on the PR (Automation), or both. Lab 3 Part 3 demos **sub-agent before PR** and **Automation after ready**.

### Target inner loop

```text
Agent implements
  → cheap CI (linters, formatters)
  → tests (pytest, smoke)
  → fresh-context final review (optional, expensive)
→ human review → merge
```

Automate the parenthesized steps gradually via scripts, `AGENTS.md`, rules, slash commands, hooks, GitHub Actions, and PR automations. Teams rarely jump to full automation on day one—and that's fine.

### Where you wire it

| Surface | Good for |
|---------|----------|
| **Local** | `scripts/check.sh` (**Lab 2:** pre-shipped; **Lab 3:** created in Part 3) or a fuller `check.py` (post-lab; ships in the Lab 3 `examples/`), `AGENTS.md`, `.cursor/rules/`, `/commit-code`, pre-commit hooks |
| **Cloud Agent** | Same `AGENTS.md` + same check script in the Dockerfile-managed VM |
| **GitHub** | Actions workflow on PR; Automations on **PR opened** or **CI completed**; Cloud Agents responding to CI/review events |

Implementation details depend on your stack and AI tool (Cursor, Copilot, Claude Code, etc.). The **pattern** is portable.

---

## Example recipes (simple → advanced)

> **Lab vs examples:** In class you practiced a subset (table above). The numbered recipes below are the same in both lab repos. Example *files* for Recipes 4–6 live in the **Lab 3** starter `examples/` folder; Lab 2’s `examples/` is the `/commit-code` template plus spec fallbacks.

### Recipe 1 — Deterministic check script

**One entry point** for humans and agents. Same command on Mac, Linux, Windows (Git Bash), and Cloud Agent Linux.

- **Lab 2:** `scripts/check.sh` is **pre-shipped**. Students **run** it; they do **not** create it in class. The shipped script runs pytest (and allows “no tests collected” until `test_model.py` exists).
- **Lab 3:** Students **create** `scripts/check.sh` in Part 3 Step 8—a minimal starter with `pip install --dry-run`, commented extension points (e.g. ruff), and `pytest`. Motivated by real agent mistakes (e.g. Streamlit pins incompatible with pinned pandas). Step 9 wires it into prompts, `AGENTS.md`, and hooks; Step 10 demos a fix pass (with the caveat that checks belong on **every** agent run, not a separate Cloud Agent only). **Step 11** repeats the review-and-merge loop on the fix PR, then confirms a working Streamlit app on `main`. Until Part 3, Lab 3 uses `python -m pytest test_sales_report.py` via `AGENTS.md` (Recipe 2).
- **Post-lab:** Extend your lab `check.sh`, or copy and grow the fuller Python template from the Lab 3 repo (`examples/scripts/check.py`).

Try the fuller example from the **Lab 3** repo root (optional, post-lab):

```bash
python examples/scripts/check.py
```

On Mac/Linux or Git Bash: `bash examples/scripts/check.sh`

**`AGENTS.md` snippet** (once you have a check script):

```markdown
Before pushing or opening a PR, run `bash scripts/check.sh` and fix all failures. Re-run until exit code 0.
```

---

### Recipe 2 — `AGENTS.md` workflow rules *(lab default)*

Encode "run tests before push" in repo-level agent instructions.

- **Lab 2:** [`AGENTS.md`](AGENTS.md) is pre-shipped with pytest / `check.sh` / tests-from-spec rules.
- **Lab 3:** Students add the testing paragraph in **Part 2**.
- **ReAct:** The agent runs pytest, reads failures, fixes code, repeats.

This is the minimum viable deterministic gate—no extra tooling required.

---

### Recipe 3 — `/commit-code` slash command *(Lab 2: created in class)*

A Cursor **slash command** that orchestrates: diff → run check script → (optional) sub-agent review → suggest commit message → ask user to confirm.

- **Lab 2:** Students create `.cursor/commands/commit-code.md` **in class** from [`examples/cursor/commands/commit-code.md`](examples/cursor/commands/commit-code.md) (copy source; omit the "EXAMPLE ONLY" header).
- **Lab 3:** `/commit-code` stays examples-only; students do not create it in that lab. The Cloud Agent golden prompt in Part 3 Step 9 is the equivalent before a PR.

**Why start here:** Easy to try, easy to adjust. Commands can take arguments (e.g. `--quick` to skip **expensive** sub-agent review). Good for teams adopting AI workflows incrementally.

**Inner loop automated:** check script + optional review. **Human** still confirms the commit.

---

### Recipe 4 — GitHub Actions CI *(example only)*

Run the **same** check script on every push/PR so GitHub is the source of truth for "green."

- **Example** (Lab 3 repo): `examples/github/workflows/ci.yml`  
  Copy to `.github/workflows/ci.yml` on your fork; point at `scripts/check.py` after adopting Recipe 1.

**Pair with Recipe 2:** Agent runs checks locally before push; CI catches anything that slipped through.

**Lab 3 Part 3 connection:** Debrief asks about a **CI completed** trigger so Automations run only after green checks—not instead of CI.

---

### Recipe 5 — PR review Automation *(Lab 3: Part 3)*

Event-driven **agent review** on GitHub after a human marks a draft PR **Ready for review**. Lab 3 uses **comments only** (Bugbot-like); a **second Cloud Agent** implements fixes on the same branch (Step 6b). This is **not** a Lab 2 exercise.

- **In Lab 3:** Part 3 hands-on
- **Example instructions** (Lab 3 repo): `examples/automations/pr-review-instructions.md`

**Trigger:** **Pull request opened** only—not **Draft opened**.

**Lab pattern:** Automation posts review comments → optional implementer Cloud Agent reads **PR #N** and pushes to the same branch → human merges one PR to `main`.

**Why not auto-fix PRs in the lab?** Agents often open fix PRs against the wrong base; stacked merges and ready-to-merge re-fires add GitHub complexity. Debrief covers this; production teams often use **Bugbot** + **`/babysit`** or comments + separate implementer.

**Position in the stack:** After deterministic CI/tests. Agent review is **expensive**—don't use it as a substitute for linters or pytest. Compare with **Bugbot** (product default) vs your custom checklist (Automations).

**What this recipe is really teaching:** **Separate implementer from final reviewer**—implementation agent, review automation, and fix agent are separate runs. Sub-agent review *before* the PR (Step 9 golden prompt) is the inner loop; PR Automation is the outer loop.

**Provider-native review vs custom Automations:** The pattern—**agent as reviewer**, triggered on PR events—is universal. Vendors are productizing it (**Bugbot**, **Approval Agents**, **`/babysit`**). Review and experiment with product features as you build your workflow.

| Approach | When to use |
|----------|-------------|
| **Provider feature** (e.g. Bugbot, Approval Agents, `/babysit`) | Default for production—better integration, maintained by the vendor |
| **Custom Automation** (this recipe) | Teach the portable pattern; encode **your** team's checklist |

**Recommendation:** Explore your provider's dedicated review features first. Lab 3 uses a **custom Automation on purpose** so you learn the general workflow—not because custom is always better.

---

### Recipe 6 — End-to-end ticket → draft PR *(aspirational example)*

A fully wired flow teams work toward—not a required lab exercise.

```text
Jira ticket (context)
  → launch Cloud Agent with ticket + AGENTS.md + rules + MCP tools
  → agent implements on branch
  → runs check script (linters + tests) in a loop until green
  → fresh sub-agent reviews diff (expensive; last automated gate)
  → opens draft PR for human review
  → (optional) GitHub CI + PR Automation on ready
  → human merges
```

**Ingredients:**

| Piece | Role |
|-------|------|
| **Jira (or Linear, etc.)** | Ticket title, acceptance criteria, links—agent context |
| **MCP / docs** | Live access to APIs, schemas, runbooks |
| **`AGENTS.md` + rules** | Repo conventions, check commands, definition of done |
| **Check script** (from example) | Cheap deterministic gates |
| **Sub-agent review** | Expensive gate before PR—budget time and model cost |
| **Draft PR + human** | Final accountability |

**Caveats:** Product support for "auto-fix on CI failure" and ticket triggers varies by tool. Start with Recipes 1–3 locally, add 4–5 on GitHub, then integrate issue trackers and MCP as the team matures.

---

## Adoption path (suggested)

In class you already practiced a subset (see [What you practiced](#what-you-practiced)). After the workshop, grow in this order:

1. **Recipe 2** — `AGENTS.md` + pytest (Lab 2 shipped; Lab 3 Part 2)
2. **Recipe 1** — `scripts/check.sh` (Lab 2 shipped; Lab 3 created in Part 3); post-lab grow via the Lab 3 `examples/scripts/check.py`
3. **Recipe 3** — `/commit-code` for local commits (Lab 2 created this in class; use `--quick` until sub-agent review is worth the cost)
4. **Recipe 4** — GitHub Actions running the same script
5. **Recipe 5** — PR Automation after ready + green CI (Lab 3 Part 3)
6. **Recipe 6** — Ticket integration + MCP + full inner-loop automation

Take small steps. Adjust prompts and gates based on what fails in practice.

---

## Related lab material

| Lab | What you practiced |
|-----|-------------------|
| **Lab 2** | Recipes 1–3 locally: shipped `check.sh`, `AGENTS.md` + pytest, create `/commit-code` |
| **Lab 3 Part 1** | Reproducible Cloud environment (same checks can run in the agent VM when you adopt them) |
| **Lab 3 Part 2** | Recipe 2 + human local verify before merge |
| **Lab 3 Part 3** | Recipes 1 + 5 — comments-only Automation, Step 6b fix agent, `check.sh`, sub-agent golden prompt; Bugbot / babysit discussion |

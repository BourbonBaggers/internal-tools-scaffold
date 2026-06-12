Report the current project status. Run all of the following and summarize the results concisely.

1. `git log --oneline -5` — recent commits
2. `git status` — uncommitted changes
3. Read `docs/plans/active-plan.md` — find the first milestone without [DONE]; that is the current milestone
4. `npm test` — test results

Report in this format:

**Branch:** <name>
**Last commit:** <hash and message>
**Active milestone:** <milestone number and title> — <one sentence on what it involves>
**Tests:** <N passed / N failed>
**Uncommitted changes:** <none, or list of modified files>

Keep it short. If tests fail, show the failure output.

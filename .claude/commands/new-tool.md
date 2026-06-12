Scaffold a new internal tool.

The tool name is: $ARGUMENTS

If $ARGUMENTS is empty, ask: "What should the tool be called? Use kebab-case — e.g. inventory-tracker, order-history, beer-log."

Once you have the name, follow these steps in order without skipping any:

## Step 1 — Generate boilerplate
Run `bash scripts/new-tool.sh <tool-name>` and show the full output.

## Step 2 — Make the 4 manual edits printed by the script
Do all four before continuing:
1. Register the route in `apps/api/src/routes/v1/index.ts`
2. Add the import and `<Route path="...">` in `apps/web/src/App.tsx`
3. Add the nav item in `apps/web/src/components/layout/Sidebar.tsx` (pick an icon from lucide-react)
4. Add the Prisma model to `prisma/schema.prisma` if the user already has a data model in mind, then run `npm run db:migrate -- --name <tool-name>`

## Step 3 — Write the plan
Ask: "Describe what this tool does and its main features in 2–3 sentences. I'll turn that into the milestone plan."

Based on their answer, write a plan file at `docs/plans/YYYY-MM-DD-<tool-name>.md` following the format in CLAUDE.md §10. Include 3–5 milestones, each representing 1–3 commits of work.

## Step 4 — Activate the plan
Run `bash scripts/archive-plan.sh` to archive the current active plan, then copy the new plan's contents into `docs/plans/active-plan.md`.

## Step 5 — Verify
Run `npm test` to confirm the stub test passes alongside the existing tests.

## Step 6 — Commit
```
git add -A
git commit -m "feat(<tool-name>): scaffold tool boilerplate"
```

## Step 7 — Hand off
Tell the user what Milestone 1 is and ask if they're ready to start building.

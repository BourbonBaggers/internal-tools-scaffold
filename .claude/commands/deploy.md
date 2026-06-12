Deploy the current main branch to production.

## Step 1 — Verify tests pass
Run `npm test`. If any tests fail, stop and report the failures. Do not proceed.

## Step 2 — Show what will be deployed
Run `git log --oneline origin/main..HEAD` to show commits not yet on the remote.
If there are no new commits, tell the user and stop — there is nothing to deploy.

## Step 3 — Confirm with the user
Show the commit list and ask:
"These N commits will be deployed to production. Ready to proceed? [y/N]"

Wait for the user's response. If they say anything other than yes/y, stop.

## Step 4 — Deploy
Run `bash scripts/deploy.sh`.

## Step 5 — Report
If the script exits 0, confirm success.
If it fails, show the error output and suggest checking `docker compose logs api` on the prod server.

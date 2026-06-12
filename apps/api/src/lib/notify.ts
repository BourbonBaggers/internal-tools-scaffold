import { env } from "../env.js";

// Priority scale: 1=min, 2=low, 3=default, 4=high, 5=urgent
// Use 4 for errors, 3 for operational events (deploys, backups), 5 only for production outages.
export async function notify(
  title: string,
  message: string,
  priority: 1 | 2 | 3 | 4 | 5 = 3,
): Promise<void> {
  if (!env.NTFY_URL || !env.NTFY_TOPIC) return;

  await fetch(`${env.NTFY_URL}/${env.NTFY_TOPIC}`, {
    method: "POST",
    headers: {
      Title: title,
      Priority: String(priority),
      "Content-Type": "text/plain",
    },
    body: message,
  }).catch(() => {
    // Intentionally swallowed — notification failures must never break application code
  });
}

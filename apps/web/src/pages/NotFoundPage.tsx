import { Link } from "react-router-dom";

export function NotFoundPage() {
  return (
    <div className="flex min-h-[400px] flex-col items-center justify-center gap-4 text-center">
      <h1 className="text-2xl font-semibold">404</h1>
      <p className="text-muted-foreground text-sm">Page not found.</p>
      <Link to="/" className="text-sm underline">
        Back to dashboard
      </Link>
    </div>
  );
}

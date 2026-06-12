import { PageTitle } from "@/components/shared/PageTitle";

export function DashboardPage() {
  return (
    <div className="flex flex-col gap-6">
      <PageTitle title="Dashboard" description="Internal tools overview" />
      <div className="rounded-lg border p-8 text-center text-sm text-muted-foreground">
        Tools will appear here as they are built.
      </div>
    </div>
  );
}

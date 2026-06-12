import { Outlet } from "react-router-dom";
import { Sidebar } from "./Sidebar";
import { TopBar } from "./TopBar";

export function AppShell() {
  return (
    <div className="flex h-screen overflow-hidden">
      {/* Desktop sidebar — hidden on mobile */}
      <aside className="hidden md:flex w-56 shrink-0 flex-col border-r bg-background">
        <div className="border-b px-4 py-3">
          <span className="font-semibold text-sm">Internal Tools</span>
        </div>
        <Sidebar />
      </aside>

      <div className="flex flex-1 flex-col overflow-hidden">
        {/* Mobile top bar with hamburger */}
        <TopBar />

        <main className="flex-1 overflow-y-auto p-4 md:p-6">
          <Outlet />
        </main>
      </div>
    </div>
  );
}

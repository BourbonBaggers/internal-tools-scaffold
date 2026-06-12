import { NavLink } from "react-router-dom";
import { LayoutDashboard } from "lucide-react";
import { cn } from "@/lib/utils";

interface NavItem {
  label: string;
  href: string;
  icon: React.ComponentType<{ size?: number; className?: string }>;
}

// Add new tools here as they are built.
// Each item appears in the sidebar and mobile navigation.
const navItems: NavItem[] = [{ label: "Dashboard", href: "/", icon: LayoutDashboard }];

interface Props {
  onNavigate?: () => void;
}

export function Sidebar({ onNavigate }: Props) {
  return (
    <nav className="flex flex-col gap-1 p-3">
      {navItems.map(({ label, href, icon: Icon }) => (
        <NavLink
          key={href}
          to={href}
          end={href === "/"}
          onClick={onNavigate}
          className={({ isActive }) =>
            cn(
              "flex h-11 items-center gap-3 rounded-md px-3 text-sm font-medium transition-colors",
              isActive
                ? "bg-accent text-accent-foreground"
                : "text-muted-foreground hover:bg-accent hover:text-accent-foreground",
            )
          }
        >
          <Icon size={18} />
          <span>{label}</span>
        </NavLink>
      ))}
    </nav>
  );
}

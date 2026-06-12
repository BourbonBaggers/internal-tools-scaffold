import { Menu } from "lucide-react";
import { Sheet, SheetContent, SheetTrigger } from "@/components/ui/sheet";
import { Button } from "@/components/ui/button";
import { Sidebar } from "./Sidebar";
import { useState } from "react";

interface Props {
  title?: string;
}

export function TopBar({ title = "Internal Tools" }: Props) {
  const [open, setOpen] = useState(false);

  return (
    <header className="border-b bg-background flex h-14 items-center gap-3 px-4">
      {/* Mobile: hamburger that opens sidebar as Sheet */}
      <Sheet open={open} onOpenChange={setOpen}>
        <SheetTrigger asChild>
          <Button variant="ghost" size="icon" className="md:hidden">
            <Menu size={20} />
            <span className="sr-only">Open navigation</span>
          </Button>
        </SheetTrigger>
        <SheetContent side="left" className="w-64 p-0">
          <div className="border-b px-4 py-3">
            <span className="font-semibold text-sm">{title}</span>
          </div>
          <Sidebar onNavigate={() => setOpen(false)} />
        </SheetContent>
      </Sheet>

      <span className="font-semibold text-sm">{title}</span>
    </header>
  );
}

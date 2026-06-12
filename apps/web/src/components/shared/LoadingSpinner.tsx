import { Loader2 } from "lucide-react";
import { cn } from "@/lib/utils";

interface Props {
  className?: string;
  size?: number;
}

export function LoadingSpinner({ className, size = 20 }: Props) {
  return (
    <Loader2
      className={cn("animate-spin text-muted-foreground", className)}
      size={size}
      aria-label="Loading"
    />
  );
}

export function PageLoadingSpinner() {
  return (
    <div className="flex min-h-[400px] items-center justify-center">
      <LoadingSpinner size={28} />
    </div>
  );
}

import { QueryClient } from "@tanstack/react-query";

export const queryClient = new QueryClient({
  defaultOptions: {
    queries: {
      // Don't retry on 4xx errors — they're client errors, not transient failures
      retry: (failureCount, error) => {
        if (error instanceof Error && "status" in error) {
          const status = (error as { status: number }).status;
          if (status >= 400 && status < 500) return false;
        }
        return failureCount < 2;
      },
      staleTime: 1000 * 60, // 1 minute
    },
  },
});

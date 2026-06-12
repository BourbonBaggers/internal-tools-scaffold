import { useQuery, type UseQueryOptions } from "@tanstack/react-query";
import { api, ApiError } from "@/lib/api";

// Generic hook for GET requests with TanStack Query.
// Automatically handles loading, error, and stale states.
export function useApi<T>(
  path: string,
  options?: Omit<UseQueryOptions<T, ApiError>, "queryKey" | "queryFn">,
) {
  return useQuery<T, ApiError>({
    queryKey: [path],
    queryFn: () => api.get<T>(path),
    ...options,
  });
}

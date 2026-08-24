/** Unwrap admin request body: `{ payload }` or raw document. */
export function unwrapPayload<T = unknown>(body: unknown): T {
  if (body && typeof body === 'object' && 'payload' in body) {
    return (body as { payload: T }).payload;
  }
  return body as T;
}

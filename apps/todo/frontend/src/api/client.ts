import type { CreateTodoInput, Todo, UpdateTodoInput } from '@todo/shared';

import { getApiUrl } from '../config';

const request = async <T>(path: string, init?: RequestInit): Promise<T> => {
  const response = await fetch(`${getApiUrl()}${path}`, {
    headers: {
      'Content-Type': 'application/json',
      ...(init?.headers ?? {}),
    },
    ...init,
  });

  if (!response.ok) {
    const payload = (await response.json().catch(() => null)) as { message?: string } | null;
    throw new Error(payload?.message ?? 'Request failed');
  }

  if (response.status === 204) {
    return undefined as T;
  }

  return (await response.json()) as T;
};

export const todoApi = {
  list: () => request<Todo[]>('/todos'),
  getById: (id: number) => request<Todo>(`/todos/${id}`),
  create: (input: CreateTodoInput) =>
    request<Todo>('/todos', {
      method: 'POST',
      body: JSON.stringify(input),
    }),
  update: (id: number, input: UpdateTodoInput) =>
    request<Todo>(`/todos/${id}`, {
      method: 'PUT',
      body: JSON.stringify(input),
    }),
  remove: (id: number) =>
    request<void>(`/todos/${id}`, {
      method: 'DELETE',
    }),
};

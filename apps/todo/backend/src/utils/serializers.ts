import type { Todo as PrismaTodo } from '@prisma/client';

import type { Todo } from '@todo/shared';

export const toTodoDto = (todo: PrismaTodo): Todo => ({
  id: todo.id,
  title: todo.title,
  completed: todo.completed,
  createdAt: todo.createdAt.toISOString(),
  updatedAt: todo.updatedAt.toISOString(),
});

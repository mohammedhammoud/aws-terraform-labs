import type { CreateTodoInput, UpdateTodoInput } from '@todo/shared';

import { prisma } from '../lib/prisma.js';
import { NotFoundError } from '../utils/errors.js';
import { toTodoDto } from '../utils/serializers.js';

export const listTodos = async () => {
  const todos = await prisma.todo.findMany({
    orderBy: {
      createdAt: 'desc',
    },
  });

  return todos.map(toTodoDto);
};

export const getTodoById = async (id: number) => {
  const todo = await prisma.todo.findUnique({ where: { id } });

  if (!todo) {
    throw new NotFoundError('Todo not found');
  }

  return toTodoDto(todo);
};

export const createTodo = async (input: CreateTodoInput) => {
  const todo = await prisma.todo.create({
    data: {
      title: input.title,
    },
  });

  return toTodoDto(todo);
};

export const updateTodo = async (id: number, input: UpdateTodoInput) => {
  const existing = await prisma.todo.findUnique({ where: { id } });

  if (!existing) {
    throw new NotFoundError('Todo not found');
  }

  const todo = await prisma.todo.update({
    where: { id },
    data: {
      title: input.title,
      completed: input.completed,
    },
  });

  return toTodoDto(todo);
};

export const deleteTodo = async (id: number) => {
  const existing = await prisma.todo.findUnique({ where: { id } });

  if (!existing) {
    throw new NotFoundError('Todo not found');
  }

  await prisma.todo.delete({ where: { id } });
};

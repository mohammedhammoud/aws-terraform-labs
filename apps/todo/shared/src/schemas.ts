import { z } from 'zod';

import { TODO_TITLE_MAX_LENGTH } from './constants.js';

export const todoIdSchema = z.coerce.number().int().positive();

export const todoSchema = z.object({
  id: z.number().int().positive(),
  title: z.string().min(1).max(TODO_TITLE_MAX_LENGTH),
  completed: z.boolean(),
  createdAt: z.string().datetime(),
  updatedAt: z.string().datetime(),
});

export const createTodoSchema = z.object({
  title: z.string().trim().min(1, 'Title is required').max(TODO_TITLE_MAX_LENGTH),
});

export const updateTodoSchema = z.object({
  title: z.string().trim().min(1, 'Title is required').max(TODO_TITLE_MAX_LENGTH),
  completed: z.boolean(),
});

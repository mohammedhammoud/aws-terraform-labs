import type { z } from 'zod';

import { createTodoSchema, todoSchema, updateTodoSchema } from './schemas.js';

export type Todo = z.infer<typeof todoSchema>;
export type CreateTodoInput = z.infer<typeof createTodoSchema>;
export type UpdateTodoInput = z.infer<typeof updateTodoSchema>;

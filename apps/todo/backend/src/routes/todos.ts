import type { FastifyPluginAsync } from 'fastify';

import { createTodoSchema, todoIdSchema, updateTodoSchema } from '@todo/shared';

import { createTodo, deleteTodo, getTodoById, listTodos, updateTodo } from '../services/todo-service.js';

export const todoRoutes: FastifyPluginAsync = async (app) => {
  app.get('/todos', async (_request, reply) => {
    const todos = await listTodos();
    return reply.send(todos);
  });

  app.get('/todos/:id', async (request, reply) => {
    const id = todoIdSchema.parse((request.params as { id: string }).id);
    const todo = await getTodoById(id);
    return reply.send(todo);
  });

  app.post('/todos', async (request, reply) => {
    const input = createTodoSchema.parse(request.body);
    const todo = await createTodo(input);
    return reply.code(201).send(todo);
  });

  app.put('/todos/:id', async (request, reply) => {
    const id = todoIdSchema.parse((request.params as { id: string }).id);
    const input = updateTodoSchema.parse(request.body);
    const todo = await updateTodo(id, input);
    return reply.send(todo);
  });

  app.delete('/todos/:id', async (request, reply) => {
    const id = todoIdSchema.parse((request.params as { id: string }).id);
    await deleteTodo(id);
    return reply.code(204).send();
  });
};

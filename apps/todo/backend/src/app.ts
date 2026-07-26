import cors from '@fastify/cors';
import Fastify from 'fastify';
import { ZodError } from 'zod';

import { corsOrigins, env } from './config/env.js';
import { getPrisma } from './lib/prisma.js';
import { healthRoutes } from './routes/health.js';
import { todoRoutes } from './routes/todos.js';
import { NotFoundError } from './utils/errors.js';

export const buildApp = () => {
  const app = Fastify({
    logger: true,
    trustProxy: env.TRUST_PROXY,
  });

  app.register(cors, {
    origin: corsOrigins.includes('*') ? true : corsOrigins,
  });
  app.register(healthRoutes);
  app.register(todoRoutes, { prefix: '/api' });

  app.setErrorHandler((error, request, reply) => {
    if (error instanceof ZodError) {
      return reply.code(400).send({
        message: 'Validation failed',
        issues: error.flatten(),
      });
    }

    if (error instanceof NotFoundError) {
      return reply.code(404).send({ message: error.message });
    }

    request.log.error(error);
    return reply.code(500).send({ message: 'Internal server error' });
  });

  app.addHook('onClose', async () => {
    await getPrisma().$disconnect();
  });

  return app;
};

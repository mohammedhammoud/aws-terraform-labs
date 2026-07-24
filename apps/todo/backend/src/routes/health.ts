import type { FastifyPluginAsync } from 'fastify';

import { prisma } from '../lib/prisma.js';
import { getIsShuttingDown } from '../lib/readiness.js';

export const healthRoutes: FastifyPluginAsync = async (app) => {
  app.get('/health', async (_request, reply) => {
    return reply.code(200).send({ status: 'ok' });
  });

  app.get('/ready', async (_request, reply) => {
    if (getIsShuttingDown()) {
      return reply.code(503).send({ status: 'error' });
    }

    try {
      await prisma.$queryRaw`SELECT 1`;
      return reply.code(200).send({ status: 'ok' });
    } catch (error) {
      app.log.error(error, 'Readiness check failed');
      return reply.code(503).send({ status: 'error' });
    }
  });
};

import { env } from './config/env.js';
import { buildApp } from './app.js';
import { initPrisma } from './lib/prisma.js';
import { markShuttingDown } from './lib/readiness.js';

const app = buildApp();

let isShuttingDown = false;

const shutdown = async (signal: NodeJS.Signals) => {
  if (isShuttingDown) {
    return;
  }

  isShuttingDown = true;
  markShuttingDown();
  app.log.info({ signal }, 'Shutdown started');

  const forceShutdownTimer = setTimeout(() => {
    app.log.error({ signal, timeoutMs: env.SHUTDOWN_TIMEOUT_MS }, 'Shutdown timed out');
    process.exit(1);
  }, env.SHUTDOWN_TIMEOUT_MS);

  try {
    await app.close();
    clearTimeout(forceShutdownTimer);
    app.log.info({ signal }, 'Shutdown complete');
    process.exit(0);
  } catch (error) {
    clearTimeout(forceShutdownTimer);
    app.log.error({ err: error, signal }, 'Shutdown failed');
    process.exit(1);
  }
};

const start = async () => {
  try {
    await initPrisma();
    await app.listen({ host: env.HOST, port: env.PORT });
  } catch (error) {
    app.log.error(error);
    process.exit(1);
  }
};

process.on('SIGTERM', () => {
  void shutdown('SIGTERM');
});

process.on('SIGINT', () => {
  void shutdown('SIGINT');
});

void start();

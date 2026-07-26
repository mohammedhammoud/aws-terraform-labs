import { PrismaClient } from '@prisma/client';

import { resolveDatabaseUrl } from '../config/database.js';

let prisma: PrismaClient | undefined;

export const initPrisma = async () => {
  const databaseUrl = await resolveDatabaseUrl();

  prisma = new PrismaClient({
    datasources: {
      db: {
        url: databaseUrl,
      },
    },
  });

  return prisma;
};

export const getPrisma = () => {
  if (!prisma) {
    throw new Error('Prisma client not initialized.');
  }

  return prisma;
};

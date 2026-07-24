import { z } from 'zod';

const envSchema = z.object({
  DATABASE_URL: z.string().min(1),
  HOST: z.string().min(1).default('0.0.0.0'),
  PORT: z.coerce.number().int().positive().default(3001),
  CORS_ORIGIN: z.string().min(1).default('http://localhost:3000'),
  TRUST_PROXY: z.coerce.boolean().default(false),
  SHUTDOWN_TIMEOUT_MS: z.coerce.number().int().positive().default(10000),
});

export const env = envSchema.parse(process.env);

export const corsOrigins = env.CORS_ORIGIN.split(',')
  .map((origin) => origin.trim())
  .filter((origin) => origin.length > 0);

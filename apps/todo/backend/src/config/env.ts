import { z } from 'zod';

const envSchema = z
  .object({
    DATABASE_URL: z.string().min(1).optional(),
    DB_SECRET_ARN: z.string().min(1).optional(),
    DB_HOST: z.string().min(1).optional(),
    DB_PORT: z.coerce.number().int().positive().optional(),
    DB_NAME: z.string().min(1).optional(),
    HOST: z.string().min(1).default('0.0.0.0'),
    PORT: z.coerce.number().int().positive().default(3001),
    CORS_ORIGIN: z.string().min(1).default('http://localhost:3000'),
    TRUST_PROXY: z.coerce.boolean().default(false),
    SHUTDOWN_TIMEOUT_MS: z.coerce.number().int().positive().default(10000),
  })
  .superRefine((value, context) => {
    const hasDatabaseUrl = value.DATABASE_URL !== undefined;
    const hasAwsFields =
      value.DB_SECRET_ARN !== undefined &&
      value.DB_HOST !== undefined &&
      value.DB_PORT !== undefined &&
      value.DB_NAME !== undefined;

    if (hasDatabaseUrl || hasAwsFields) {
      return;
    }

    context.addIssue({
      code: z.ZodIssueCode.custom,
      message: 'Set DATABASE_URL or all of DB_SECRET_ARN, DB_HOST, DB_PORT, and DB_NAME.',
      path: ['DATABASE_URL'],
    });
  });

export const env = envSchema.parse(process.env);

export const corsOrigins = env.CORS_ORIGIN.split(',')
  .map((origin) => origin.trim())
  .filter((origin) => origin.length > 0);

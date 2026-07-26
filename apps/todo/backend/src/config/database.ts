import { SecretsManagerClient, GetSecretValueCommand } from '@aws-sdk/client-secrets-manager';
import { z } from 'zod';

import { env } from './env.js';

const awsDatabaseEnvSchema = z.object({
  DB_SECRET_ARN: z.string().min(1),
  DB_HOST: z.string().min(1),
  DB_PORT: z.number().int().positive(),
  DB_NAME: z.string().min(1),
});

const rdsSecretSchema = z.object({
  username: z.string().min(1),
  password: z.string().min(1),
});

export const resolveDatabaseUrl = async (): Promise<string> => {
  if (env.DATABASE_URL) {
    return env.DATABASE_URL;
  }

  const awsEnv = awsDatabaseEnvSchema.parse(env);
  const client = new SecretsManagerClient();
  const response = await client.send(
    new GetSecretValueCommand({
      SecretId: awsEnv.DB_SECRET_ARN,
    }),
  );

  const secretString = response.SecretString;

  if (!secretString) {
    throw new Error('RDS master secret did not include SecretString.');
  }

  const secret = rdsSecretSchema.parse(JSON.parse(secretString));
  const username = encodeURIComponent(secret.username);
  const password = encodeURIComponent(secret.password);
  const databaseName = encodeURIComponent(awsEnv.DB_NAME);

  return `postgresql://${username}:${password}@${awsEnv.DB_HOST}:${awsEnv.DB_PORT}/${databaseName}`;
};

import { spawn } from 'node:child_process';
import { dirname, resolve } from 'node:path';
import { fileURLToPath } from 'node:url';
import { createRequire } from 'node:module';

import { resolveDatabaseUrl } from '../config/database.js';

const require = createRequire(import.meta.url);

const run = async () => {
  const databaseUrl = await resolveDatabaseUrl();
  const currentFilePath = fileURLToPath(import.meta.url);
  const backendRoot = resolve(dirname(currentFilePath), '..', '..');
  const schemaPath = resolve(backendRoot, 'prisma', 'schema.prisma');
  const prismaCliEntrypoint = require.resolve('prisma/build/index.js');

  const child = spawn(
    process.execPath,
    [prismaCliEntrypoint, 'migrate', 'deploy', '--schema', schemaPath],
    {
      cwd: backendRoot,
      env: {
        ...process.env,
        DATABASE_URL: databaseUrl,
      },
      stdio: 'inherit',
    },
  );

  child.on('error', (error) => {
    console.error('Failed to start Prisma migrate deploy.', error);
    process.exit(1);
  });

  child.on('exit', (code, signal) => {
    if (signal) {
      process.kill(process.pid, signal);
      return;
    }

    process.exit(code ?? 1);
  });
};

void run().catch((error) => {
  console.error('Migration runner failed before Prisma started.', error);
  process.exit(1);
});

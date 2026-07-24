type RuntimeConfig = {
  API_URL?: string;
};

let runtimeConfig: RuntimeConfig = {};

const buildTimeApiUrl = import.meta.env.VITE_API_URL?.trim();

export const loadConfig = async () => {
  try {
    const response = await fetch('/config.json', { cache: 'no-store' });

    if (!response.ok) {
      return;
    }

    runtimeConfig = (await response.json()) as RuntimeConfig;
  } catch {
    runtimeConfig = {};
  }
};

export const getApiUrl = () => runtimeConfig.API_URL?.trim() || buildTimeApiUrl || 'http://localhost:3001';

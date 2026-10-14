import { resolve } from 'node:path';
import { fileURLToPath } from 'node:url';
import { defineConfig, loadEnv } from 'vite';
import react from '@vitejs/plugin-react';
import { seoTokensPlugin } from './scripts/seo-config.mjs';

const projectRoot = fileURLToPath(new URL('.', import.meta.url));

export default defineConfig(({ mode }) => {
    const port = Number(process.env.PORT) || 3000;
    // VITE_ vars are resolved from .env files so SEO tokens match the runtime config.
    const env = loadEnv(mode, projectRoot, '');
    return {
      server: {
        port,
        strictPort: Boolean(process.env.PORT),
        host: '0.0.0.0',
      },
      plugins: [react(), seoTokensPlugin(env)],
      resolve: {
        alias: {
          '@': resolve(projectRoot),
        }
      }
    };
});

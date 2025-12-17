import { defineConfig, loadEnv } from 'vite';
import react from '@vitejs/plugin-react';
import process from 'node:process';

export default defineConfig(({ mode }) => {
  const env = loadEnv(mode, process.cwd(), '');
  
  // W trybie deweloperskim (npm run dev) używamy .env
  // W trybie produkcyjnym (build) zostawiamy puste, bo Docker podstawi to w window._env_
  const apiKey = process.env.API_KEY || env.API_KEY || '';

  return {
    plugins: [react()],
    define: {
      // Zostawiamy to dla kompatybilności lokalnej (npm run dev)
      'process.env.API_KEY': JSON.stringify(apiKey)
    },
    server: {
      host: true,
      port: 5173
    }
  };
});
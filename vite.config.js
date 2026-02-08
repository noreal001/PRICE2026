import { defineConfig } from 'vite'
import vue from '@vitejs/plugin-vue'

export default defineConfig({
  plugins: [vue()],
  server: {
    host: true
  },
  preview: {
    host: true,
    allowedHosts: ['railway.app', 'up.railway.app']
  }
})

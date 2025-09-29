import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'
import { viteSingleFile } from "vite-plugin-singlefile"
import tailwindcss from '@tailwindcss/vite'
import flowbiteReact from "flowbite-react/plugin/vite";

// https://vite.dev/config/
export default defineConfig({
  build: {
    outDir: "../iris", // relative to source dir
    emptyOutDir: true
  },
  plugins: [react(),
  tailwindcss(),
  flowbiteReact(),
  viteSingleFile()],
})
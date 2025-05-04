import "./assets/main.scss"

import Oruga from '@oruga-ui/oruga-next';
import { bulmaConfig } from '@oruga-ui/theme-bulma';

import { createApp } from 'vue'
import { createPinia } from 'pinia'
import App from './App.vue'


const app = createApp(App)

app.use(createPinia(), Oruga, bulmaConfig)
app.mount('#app')
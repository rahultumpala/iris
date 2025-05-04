<script setup>
import { inject } from "vue"

const { theme, toggleTheme } = inject("globalTheme")
</script>

<template>
    <nav class="navbar is-dark" role="navigation" aria-label="main navigation" :class="theme">
        <div class="navbar-brand">
            <div class="navbar-item">
                IRIS
            </div>
        </div>
        <div id="navbarBasicExample" class="navbar-menu">
            <div class="navbar-start">
                <a class="navbar-item" @click="toggleTheme">
                    Theme {{ theme }}
                </a>
                <a class="navbar-item">
                    Github
                </a>
            </div>
        </div>
    </nav>
</template>

<style scoped></style>

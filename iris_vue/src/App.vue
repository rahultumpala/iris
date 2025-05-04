<script setup>
import { provide, ref } from "vue";
import Navbar from "./components/Navbar.vue";
import ApplicationsMenu from "./components/ApplicationsMenu.vue";

const theme = ref("dark");
function toggleTheme() {
  if (theme.value == "dark") theme.value = "light";
  else theme.value = "dark";
}
provide("globalTheme", {
  theme,
  toggleTheme,
});
</script>

<template>
  <div class="rootapp" :data-theme="theme">
    <Navbar></Navbar>
    <div class="columns">
      <ApplicationsMenu></ApplicationsMenu>
    </div>
  </div>
</template>

<style scoped></style>

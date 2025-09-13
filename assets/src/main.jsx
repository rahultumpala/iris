import { StrictMode } from "react";
import { createRoot } from "react-dom/client";
import "./assets/index.css";
import App from "./components/App.jsx";
import { GlobalProvider } from "./ctx/globalContext.jsx";

// all ExDoc related stylesheets.
import.meta.glob("./assets/content/*.css", { eager: true });
import.meta.glob("./assets/custom-props/*.css", { eager: true });

createRoot(document.getElementById("root")).render(
  <StrictMode>
    <GlobalProvider>
      <App />
    </GlobalProvider>
  </StrictMode>
);

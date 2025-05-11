import { useEffect } from "react";

import { useGlobalDispatch } from "../ctx/globalContext.jsx";

import { SidebarComponent } from "./Sidebar.jsx";
import { ButtonComponent } from "./Button.jsx";

function App() {
  const globalDispatch = useGlobalDispatch();
  useEffect(() => {
    /*
    FETCH ENTITY FROM FILE
    CREATE GLOBAL STATE OBJECT
    */
    async function initGlobalState() {
      let response = await fetch("entity.json");
      let entity = await response.json();
      console.log(entity);

      let globalState = {
        entity,
        selectedApplication: null,
        selectedModule: null,
        selectedMethod: null,
      };

      globalDispatch({
        type: "setGlobalState",
        globalState,
      });
    }

    return initGlobalState;
  }, [globalDispatch]);

  return (
    <>
      <div class="app">
        <SidebarComponent></SidebarComponent>
        <ButtonComponent></ButtonComponent>
      </div>
    </>
  );
}

export default App;

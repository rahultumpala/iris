import { useEffect } from "react";

import { useGlobalDispatch, useGlobalState } from "../ctx/globalContext.jsx";
import { LeftHalf } from "./LeftHalf.jsx";
import { RightHalf } from "./RightHalf.jsx";
import { LoadingState } from "./LoadingState.jsx";

function App() {
  const globalDispatch = useGlobalDispatch();
  let state = useGlobalState();
  useEffect(() => {
    /*
    FETCH ENTITY FROM FILE
    CREATE GLOBAL STATE OBJECT
    */
    async function initGlobalState() {
      let response = await fetch("entity.json");
      let entity = await response.json();

      let globalState = {
        entity,
        selectedApplication: entity.applications[0],
        selectedModule: entity.applications[0].modules[0],
        selectedMethod: entity.applications[0].modules[0].methods[0],
      };

      globalDispatch({
        type: "setGlobalState",
        globalState,
      });
    }

    return initGlobalState;
  }, []);

  if (state == null) return <LoadingState></LoadingState>;
  else {
    return (
      <>
        <div className="app">
          <LeftHalf></LeftHalf>
          <RightHalf></RightHalf>
        </div>
      </>
    );
  }
}

export default App;

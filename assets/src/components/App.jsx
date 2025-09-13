import { useEffect } from "react";

import { useGlobalDispatch, useGlobalState } from "../ctx/globalContext.jsx";
import { LeftHalf } from "./LeftHalf.jsx";
import { RightHalf } from "./RightHalf.jsx";
import { LoadingState } from "./LoadingState.jsx";
import { GlobalConstants } from "../constants.js";
import { FetchFailedState } from "./FetchFailedState.jsx";
import loadScript from "../helpers/loadScript.js";

function App() {
  const globalDispatch = useGlobalDispatch();
  let state = useGlobalState();

  async function loadSuccess_initGlobalState() {
    if (state != null) return;

    const entity = getGlobalEntity(); // getGlobalEntity() is exported by entity.js which is loaded dynamically

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

  const initFailedCallback = () => {
    globalDispatch({
      type: GlobalConstants.ENTITY_FETCH_FAILED,
    });
  };

  useEffect(() => {
    // trigger dynamic loading of entity.js into the app ONLY when state is null
    if (state == null) {
      loadScript(loadSuccess_initGlobalState, initFailedCallback);
    }
  }, []);

  if (state == null) return <LoadingState></LoadingState>;
  else if (state == GlobalConstants.ENTITY_FETCH_FAILED)
    return <FetchFailedState></FetchFailedState>;
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

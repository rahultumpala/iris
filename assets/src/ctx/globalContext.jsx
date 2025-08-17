import { createContext, useContext, useReducer } from "react";

const GlobalCtx = createContext(null);
const GlobalDispatchCtx = createContext(null);

export function GlobalProvider({ children }) {
  const [globalState, dispatch] = useReducer(globalReducer, null); // no init state

  return (
    <GlobalCtx.Provider value={globalState}>
      <GlobalDispatchCtx.Provider value={dispatch}>
        {children}
      </GlobalDispatchCtx.Provider>
    </GlobalCtx.Provider>
  );
}

/*
modifies curState based on the action and returns new state
*/
function globalReducer(curState, action) {
  switch (action.type) {
    case "selectApplication": {
      return {
        ...curState,
        ...chooseApplicationAndDescendants(action.application),
        showDocumentation: false,
      };
    }
    case "selectModule": {
      return {
        ...curState,
        ...chooseModuleAndDescendants(curState, action.module),
        showDocumentation: false,
      };
    }
    case "selectMethod": {
      return {
        ...curState,
        selectedMethod: action.method,
        showDocumentation: false,
      };
    }
    case "setGlobalState": {
      // invoked only at the beginning of the app
      console.log("Setting Global State", action.globalState);
      return {
        ...action.globalState,
        // DEFAULTS: Flow direction, Toggle Button Text, Documentation Card Display
        flowDirection: "V",
        flowDirectionToggleText: "View Horizontal",
        showDocumentation: false,
      };
    }
    case "toggleFlowDirection": {
      // ignores the action as this is only a toggle.
      console.log(
        "toggling flow direction",
        curState,
        toggleFlowDirection(curState)
      );
      return toggleFlowDirection(curState);
    }
    case "toggleDocumentationDisplay": {
      // ignores the action as this is only a toggle.
      console.log(
        "toggling documentation display",
        curState,
        toggleDocumentationDisplay(curState)
      );
      return toggleDocumentationDisplay(curState);
    }
    default: {
      throw Error("Unknown action: " + action.type);
    }
  }
}

/*
custom hooks
*/
export function useGlobalState() {
  return useContext(GlobalCtx);
}

export function useGlobalDispatch() {
  return useContext(GlobalDispatchCtx);
}

/* internal helpers */
function chooseModuleAndDescendants(state, module) {
  const app = state.entity.applications.filter(
    (app) => app.application === module.application
  )[0]; // Possible bug when selected there's no app for selected module in loaded apps
  const method = chooseMethod(module);
  return {
    selectedApplication: app,
    selectedModule: module,
    selectedMethod: method,
  };
}

function chooseApplicationAndDescendants(app) {
  const module = app.modules?.[0];
  const method = chooseMethod(module);
  return {
    selectedApplication: app,
    selectedModule: module,
    selectedMethod: method,
  };
}

function chooseMethod(module) {
  let method = module?.methods?.[0];
  method =
    method["html_type_text"] == "INT" || method["html_type_text"] == "EXP"
      ? method
      : null;
  return method;
}

function toggleFlowDirection(state) {
  let currentDir = state.flowDirection;
  let newDir = currentDir == "H" ? "V" : "H";
  let displayText = newDir == "H" ? "View Vertical" : "View Horizontal";

  return {
    ...state,
    flowDirection: newDir,
    flowDirectionToggleText: displayText,
    showDocumentation: false,
  };
}

function toggleDocumentationDisplay(state) {
  return {
    ...state,
    showDocumentation: !state.showDocumentation,
  };
}

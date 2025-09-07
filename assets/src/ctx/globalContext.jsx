import { createContext, useContext, useReducer } from "react";
import {
  getTogglePathExpansionDetails,
  getAllModules,
} from "../helpers/stateHelper";

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
    // <<< SET INIT DEFAULTS HERE >>>
    case "setGlobalState": {
      // invoked only at the beginning of the app
      console.log("Setting Global State", action.globalState);
      return {
        ...action.globalState,
        // DEFAULTS: Flow direction, Toggle Button Text, Documentation Card Display
        flowDirection: "V",
        flowDirectionToggleText: "View Horizontal",
        showDocumentation: false,
        docsMethod: undefined, // this will be used when set. else [selectedMethod] will be used as fallback
        // this is to be used when pathExpansion is toggled by clicking on a clickable node in the flow
        togglePathExpansion: {
          method: undefined,
          module: undefined,
          node: undefined,
        },
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
      /*
        [action.docsMethod] - display docs of this method
        [action.keepDisplaying] - bool - this will be true when docs btn of some other method is clicked.
            do not stop displaying the docs component. update the content.
            when false - stop displaying the docs component.
      */
      return toggleDocumentationDisplay(
        curState,
        action.docsMethod,
        action.keepDisplaying
      );
    }
    case "togglePathExpansion": {
      /*
        Path expansion is toggled for nodes that are NOT already expanded
        Multiple nodes CAN be in the expanded state simultaneously
        Flow generator MUST figure out whether the [toggleNode] is already expanded or not.
        Path expansion triggers a flow re-render
      */
      return togglePathExpansion(curState, action.toggleNode);
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
  const method = chooseDefaultMethod(module);
  return {
    selectedApplication: app,
    selectedModule: module,
    selectedMethod: method,
  };
}

function chooseApplicationAndDescendants(app) {
  const module = app.modules?.[0];
  const method = chooseDefaultMethod(module);
  return {
    selectedApplication: app,
    selectedModule: module,
    selectedMethod: method,
  };
}

function chooseDefaultMethod(module) {
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

function toggleDocumentationDisplay(state, method, keepDisplaying) {
  return {
    ...state,
    showDocumentation:
      keepDisplaying == false && state.showDocumentation ? false : true,
    docsMethod: method || state.selectedMethod, // use state.selectedMethod as the default fallback
  };
}

function togglePathExpansion(curState, toggleNode) {
  return {
    ...curState,
    togglePathExpansion: getTogglePathExpansionDetails(
      getAllModules(curState),
      toggleNode
    ),
  };
}

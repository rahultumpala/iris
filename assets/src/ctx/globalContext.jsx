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
      console.log(`Selected Application ${action.application}`)
      return {
        ...curState,
        selectedApplication: action.application,
      };
    }
    case "selectModule": {
      return {
        ...curState,
        selectedModule: action.module,
      };
    }
    case "selectMethod": {
      return {
        ...curState,
        selectedMethod: action.method,
      };
    }
    case "setGlobalState": {
      console.log("Setting Global State");
      return action.globalState;
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

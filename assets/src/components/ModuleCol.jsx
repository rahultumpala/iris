import { useGlobalState, useGlobalDispatch } from "../ctx/globalContext.jsx";

import { SidebarItem } from "flowbite-react";

function ModuleItem({ module, selectedModule }) {
  const dispatch = useGlobalDispatch();
  let selectModule = () => {
    dispatch({ type: "selectModule", module: module });
  };
  const isSelected = module == selectedModule;
  const className = "text-sm w-auto " + (isSelected ? "selected-module" : "");

  return (
    <>
      <SidebarItem className={className}>
        <div className="module_item" onClick={selectModule}>
          {module.module}
        </div>
      </SidebarItem>
    </>
  );
}

export function ModuleColumn() {
  const state = useGlobalState();
  const app = state.selectedApplication;

  if (app.modules == undefined || app.modules == null) {
    return (
      <SidebarItem>
        <div className="no_modules">No Modules</div>
      </SidebarItem>
    );
  }

  return (
    <>
      {/* Title */}
      <div className="col_title_text">
        <p className="">{app.application}</p>
      </div>

      {/* Module Items List */}
      <div className="module_col">
        {app.modules.map((mod, idx) => (
          <ModuleItem
            key={mod.module}
            module={mod}
            selectedModule={state.selectedModule}
          ></ModuleItem>
        ))}
      </div>
    </>
  );
}

import { useGlobalState, useGlobalDispatch } from "../ctx/globalContext.jsx";

import { SidebarItem } from "flowbite-react";

function ModuleItem({ module }) {
  return (
    <>
      <SidebarItem className="text-sm">
        <div className="module_item">{module.module}</div>
      </SidebarItem>
    </>
  );
}

export function ModuleColumn() {
  const state = useGlobalState();
  console.log(state);
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
        <p className="">Modules</p>
      </div>

      {/* Module Items List */}
      <div className="module_col">
        {app.modules.map((mod, idx) => (
          <ModuleItem key={mod.module} module={mod}></ModuleItem>
        ))}
      </div>
    </>
  );
}

import { useGlobalState, useGlobalDispatch } from "../ctx/globalContext.jsx";

import { SidebarItem } from "flowbite-react";

function MethodType({ text, tooltip }) {
  return (
    <>
      <div className="method_type text-sm text-gray">{text}</div>
    </>
  );
}

function MethodItem({ method }) {
  return (
    <>
      <SidebarItem>
        <div className="method_item flex flex-row justify-between items-center">
          <div className="method_text mr-5 text-sm">
            {method.name} / {method.arity}
          </div>
          <MethodType
            text={method.html_type_text}
            tooltip={method.tooltip_text}
          ></MethodType>
        </div>
      </SidebarItem>
    </>
  );
}

export function MethodColumn() {
  const state = useGlobalState();
  const module = state.selectedModule;
  if (
    module == undefined ||
    module == null ||
    module.methods == undefined ||
    module.methods == null
  ) {
    return (
      <SidebarItem>
        <div className="no_methods">No Methods</div>
      </SidebarItem>
    );
  }

  return (
    <>
      {/* Title */}
      <div className="col_title_text">
        <p className="">{module.module}</p>
      </div>
      {/* Method Items List */}
      <div className="method_col">
        {module.methods.map((method, idx) => (
          <MethodItem key={idx} method={method}></MethodItem>
        ))}
      </div>
    </>
  );
}

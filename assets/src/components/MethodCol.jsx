import { useGlobalState, useGlobalDispatch } from "../ctx/globalContext.jsx";

import { SidebarItem, Tooltip } from "flowbite-react";

function MethodType({ text, tooltip }) {
  const attributes = {
    className: `method-type text-xs ${
      text == "INT" ? "method-type-internal" : "method-ext"
    }`,
  };

  return (
    <>
      <Tooltip content={tooltip} placement="right" className="text-xs font-normal bg-gray-900 ">
        <div {...attributes}>{text}</div>
      </Tooltip>
    </>
  );
}

function MethodItem({ method }) {
  const dispatch = useGlobalDispatch();
  const selectMethod = () => {
    dispatch({
      type: "selectMethod",
      method: method,
    });
  };

  const clickable =
    method.html_type_text == "INT" || method.html_type_text == "EXT";

  const attributes = {
    onClick: clickable ? selectMethod : null,
    className: clickable ? "method-item clickable-method" : "method-item",
  };

  return (
    <>
      <SidebarItem {...attributes}>
        <div className="flex flex-row justify-between items-center">
          <div className="method-text mr-5 text-sm">
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

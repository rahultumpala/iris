import { useGlobalState } from "../ctx/globalContext.jsx";
import { useRef } from "react";

export function MethodHeader() {
  const state = useGlobalState();
  const method = state.selectedMethod;
  const ref = useRef(null); // to re-render component when state changes

  if (method == null || method == undefined) {
    return (
      <>
        <div className="method-header col_title_text text-md">
          No Method Selected
        </div>
      </>
    );
  }
  ``;

  return (
    <>
      <div className="method-header" ref={ref}>
        <div className="col_title_text text-md">
          {method.name} / {method.arity}{" "}
        </div>
      </div>
    </>
  );
}

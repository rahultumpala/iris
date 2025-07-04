import { useGlobalState } from "../ctx/globalContext.jsx";
import { useRef } from "react";
import { Button } from "flowbite-react";

export function MethodHeader() {
  const state = useGlobalState();
  const method = state.selectedMethod;
  const ref = useRef(null); // to re-render component when state changes
  const hasDoc = method?.["ex_doc"] != null;

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
      <div
        className="method-header flex flex-row items-center align-center"
        ref={ref}
      >
        <div className="col_title_text text-md">
          {method.name} / {method.arity}{" "}
        </div>
        <div className="m-2">
          <Button size="sm" color="alternative" disabled={!hasDoc}>
            Doc
          </Button>
        </div>
      </div>
    </>
  );
}

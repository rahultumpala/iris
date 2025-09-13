import { useGlobalDispatch, useGlobalState } from "../ctx/globalContext.jsx";
import { useRef } from "react";
import { Button } from "flowbite-react";
import { methodHasDocumentation } from "../helpers/stateHelper.js";

export function MethodHeader() {
  const state = useGlobalState();
  const dispatch = useGlobalDispatch();

  const method = state.selectedMethod;
  const ref = useRef(null); // to re-render component when state changes

  const hasDoc = methodHasDocumentation(method);

  const showDocumentation = () => {
    dispatch({
      type: "toggleDocumentationDisplay",
      docsMethod: method,
      keepDisplaying: false,
    });
  };

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
          <Button
            size="sm"
            color="alternative"
            disabled={!hasDoc}
            onClick={showDocumentation}
          >
            Doc
          </Button>
        </div>
      </div>
    </>
  );
}

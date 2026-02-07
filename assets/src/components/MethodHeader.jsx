import { useGlobalDispatch, useGlobalState } from "../ctx/globalContext.jsx";
import { useRef } from "react";
import { methodHasDocumentation } from "../helpers/stateHelper.js";
import { Heading } from "./ui/heading.jsx";
import { Button } from "./ui/button.jsx";

export function MethodHeader() {
  const state = useGlobalState();
  const dispatch = useGlobalDispatch();

  const method = state.selectedMethod;
  const ref = useRef(null); // to re-render component when state changes

  const hasDoc = methodHasDocumentation(method);

  const showDocumentation = () => {
    dispatch({
      type: "toggleDocumentationDisplay",
      docsEntity: method,
      docsType: "method",
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
        <div className="col_title_text">
          <Heading level={4}>
            {method.name} / {method.arity}
          </Heading>
        </div>
        <div className="m-2">
          <Button
            intent={"outline"}
            isDisabled={!hasDoc}
            onClick={showDocumentation}
          >
            Doc
          </Button>
        </div>
      </div>
    </>
  );
}

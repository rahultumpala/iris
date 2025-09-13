import { Tooltip } from "flowbite-react";
import { useGlobalDispatch, useGlobalState } from "../ctx/globalContext";

export function DocumentationIcon({ className, method }) {
  const dispatch = useGlobalDispatch();

  const showDocumentation = () => {
    console.log("clicked");
    dispatch({
      type: "toggleDocumentationDisplay",
      docsMethod: method,
    });
  };

  return (
    <div className={"node-docs-icon " + className} onClick={showDocumentation}>
      <Tooltip
        content="Documentation"
        placement="right"
        className="text-xs font-normal bg-gray-900"
      >
        <div className={"img-container "}>
          <img
            className="docs-icon-svg"
            src="docs.png"
            alt="docs-icon"
            width="15"
            height="10"
          ></img>
        </div>
      </Tooltip>
    </div>
  );
}

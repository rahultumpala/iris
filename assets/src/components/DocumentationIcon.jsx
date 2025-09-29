import { Tooltip } from "flowbite-react";
import { useGlobalDispatch, useGlobalState } from "../ctx/globalContext";

export function DocumentationIcon({ className, method, module }) {
  const dispatch = useGlobalDispatch();

  const showDocumentation = () => {
    dispatch({
      type: "toggleDocumentationDisplay",
      docsEntity: method != null ? method : module,
      docsType: method != null ? "method" : "module",
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
            width="20"
            height="15"
          ></img>
        </div>
      </Tooltip>
    </div>
  );
}

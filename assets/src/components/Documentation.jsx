import { useGlobalState, useGlobalDispatch } from "../ctx/globalContext.jsx";
import { Card, Button } from "flowbite-react";
import Markdown from "react-markdown";
import { getMethodDocs } from "../helpers/stateHelper.js";

export function Documentation({}) {
  const state = useGlobalState();
  const dispatch = useGlobalDispatch();

  const method = state.docsMethod;
  const docMarkdown = getMethodDocs(method);
  const showDocumentation = state.showDocumentation;

  const toggle = () => {
    dispatch({
      type: "toggleDocumentationDisplay",
      keepDisplaying: false, // a hack to switch off the display when pressed again, instead of re-rendering the content.
    });
  };

  if (showDocumentation) {
    return (
      <Card className="doc-card">
        <div className="doc-card-header">
          <h5 className="text-xl font-bold tracking-tight text-gray-900">
            Documentation
          </h5>
          <Button
            size="sm"
            color="alternative"
            onClick={toggle}
            className="doc-card-close-btn"
          >
            x
          </Button>
        </div>
        <div className="markdown content-inner">
          <Markdown>{docMarkdown}</Markdown>
        </div>
      </Card>
    );
  }
  return <></>;
}

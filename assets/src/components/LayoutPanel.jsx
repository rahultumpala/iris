import { Panel } from "@xyflow/react";
import { ButtonGroup, Button } from "flowbite-react";
import { useGlobalState, useGlobalDispatch } from "../ctx/globalContext.jsx";

export function LayoutPanel({}) {
  /*
   state is not being used, it is here to listen to changes
   and to reset the direction toggle button.
  */
  const state = useGlobalState();
  const dispatch = useGlobalDispatch();

  const toggleDirection = () => {
    dispatch({
      type: "toggleFlowDirection",
    });
  };

  const text = state.flowDirectionToggleText;

  return (
    <Panel position="top-right">
      <ButtonGroup>
        <Button
          color="alternative"
          className="text-sm"
          onClick={toggleDirection}
        >
          {text}
        </Button>
      </ButtonGroup>
    </Panel>
  );
}

import { Panel } from "@xyflow/react";
import { useGlobalState, useGlobalDispatch } from "../ctx/globalContext.jsx";
import { Button } from "./ui/button.jsx";

export function LayoutPanel({ }) {
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
      <Button intent={"outline"} onClick={toggleDirection}>
        {text}
      </Button>
      {/* <Button
          color="alternative"
          className="text-sm"
          onClick={toggleDirection}
        >
          {text}
        </Button> */}
    </Panel>
  );
}

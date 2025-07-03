import { Panel } from "@xyflow/react";
import { ButtonGroup, Button } from "flowbite-react";
import { useEffect, useState } from "react";
import { GlobalConstants } from "../constants";

const H = "View Horizontal";
const V = "View Vertical";

export function LayoutPanel({ onLayout }) {
  const toggleDir = (dir) => {
    if (dir == "H") return "V";
    else return "H";
  };
  const getText = (dir) => {
    if (dir == "H") return V;
    return H;
  };

  const initialDir = GlobalConstants.DEFAULT_GRAPH_DIRECTION;
  const [dir, setDir] = useState(initialDir);

  const displayText = getText(dir);
  const [text, setText] = useState(displayText);

  useEffect(() => {
    if (dir == "V") setText(H);
    else setText(V);
  }, [dir]);

  return (
    <Panel position="top-right">
      <ButtonGroup>
        <Button
          color="alternative"
          className="text-sm"
          onClick={() => {
            const new_dir = toggleDir(dir);
            setDir(new_dir);
            onLayout(new_dir);
          }}
        >
          {text}
        </Button>
      </ButtonGroup>
    </Panel>
  );
}

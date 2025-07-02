import { Panel } from "@xyflow/react";
import { ButtonGroup, Button } from "flowbite-react";
import { useEffect, useRef, useState } from "react";

const H = "View Horizontal";
const V = "View Vertical";

export function LayoutPanel({ onLayout }) {
  // initial direction is V so setting display text to H
  const displayText = H;
  const [text, setText] = useState(displayText);

  // initial direction - if changed then change initial node types in Flow.jsx nodes also
  const initialDir = "V";
  const [dir, setDir] = useState(initialDir);

  const toggleDir = (dir) => {
    if (dir == "H") setDir("V");
    else setDir("H");
  };

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
            toggleDir(dir);
            onLayout(dir);
          }}
        >
          {text}
        </Button>
      </ButtonGroup>
    </Panel>
  );
}

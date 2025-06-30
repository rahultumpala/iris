import { Flow } from "./Flow.jsx";
import { MethodHeader } from "./MethodHeader.jsx";
import { ReactFlowProvider } from "@xyflow/react";

export function RightHalf() {
  return (
    <>
      <div className="right-half flex flex-col">
        {/* Method Information */}
        <MethodHeader></MethodHeader>

        {/* React Flow UI */}
        <ReactFlowProvider>
          <Flow></Flow>
        </ReactFlowProvider>
      </div>
    </>
  );
}

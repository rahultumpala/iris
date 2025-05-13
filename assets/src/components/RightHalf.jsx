import { Flow } from "./Flow.jsx";
import { MethodHeader } from "./MethodHeader.jsx";

export function RightHalf() {
  return (
    <>
      <div className="right-half flex flex-col">
        {/* Method Information */}
        <MethodHeader></MethodHeader>

        {/* React Flow UI */}
        <Flow></Flow>
      </div>
    </>
  );
}

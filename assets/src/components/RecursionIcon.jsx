import { Tooltip } from "flowbite-react";

export function RecursionIcon({ className, selectedMethod }) {
  return (
    <div className={"node-recursive-tag " + className}>
      <Tooltip
        content="Recursive Method"
        placement="right"
        className="text-xs font-normal bg-gray-900"
      >
        <div
          className={
            "img-container " + (selectedMethod ? "selected-method" : "")
          }
        >
          <img
            class="recursion-svg"
            src="rec-3.png"
            alt="recursive-icon"
            width="15"
            height="10"
          ></img>
        </div>
      </Tooltip>
    </div>
  );
}

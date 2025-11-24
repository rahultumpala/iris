import { Tooltip } from "flowbite-react";

export function MacroIcon({ className }) {
  return (
    <div className={"macro-icon " + className}>
      <Tooltip
        content="Macro"
        placement="right"
        className="text-xs font-normal bg-gray-900"
      >
        <div className={"img-container "}>
          <img
            className="macro-icon-svg"
            src="macro.svg"
            alt="macro-icon"
            width="20"
            height="15"
          ></img>
        </div>
      </Tooltip>
    </div>
  );
}

import { useGlobalState } from "../ctx/globalContext.jsx";
import { Card } from "flowbite-react";

export function Documentation({}) {
  const state = useGlobalState();

  return (
    <Card className="max-w-sm">
      <h5 className="text-xl font-bold tracking-tight text-gray-900 dark:text-white">
        Documentation
      </h5>
    </Card>
  );
}

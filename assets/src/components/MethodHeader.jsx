import { useGlobalState } from "../ctx/globalContext.jsx";

export function MethodHeader() {
  const state = useGlobalState();
  const method = state.selectedMethod;

  if (method == null || method == undefined) {
    return (
      <>
        <div className="no_methods text-md">No Method Selected</div>
      </>
    );
  }

  return (
    <>
      <div className="method-header">
        <div className="col_title_text text-md">
          {method.name} / {method.arity}{" "}
        </div>
      </div>
    </>
  );
}

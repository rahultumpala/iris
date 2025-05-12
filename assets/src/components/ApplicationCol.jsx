import { useGlobalState, useGlobalDispatch } from "../ctx/globalContext.jsx";

function ApplicationItem() {
  return (
    <>
      <div className="app_item"></div>
    </>
  );
}

export function ApplicationColumn() {
  const state = useGlobalState();
  const applications = state.entity.applications.map((app) => app.application);
  console.log(applications);
  // TODO: Render List
  return (
    <>
      <div className="app_col"></div>
    </>
  );
}

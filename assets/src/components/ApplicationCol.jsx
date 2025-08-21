import { useGlobalState, useGlobalDispatch } from "../ctx/globalContext.jsx";

import { SidebarItem } from "flowbite-react";

function ApplicationItem({ app, selectedApp }) {
  const dispatch = useGlobalDispatch();
  let selectApplication = () => {
    dispatch({ type: "selectApplication", application: app });
  };

  const isSelected = app == selectedApp;
  const className = isSelected ? "selected-app" : "";

  return (
    <>
      <SidebarItem className={className}>
        <div className="application_item text-md" onClick={selectApplication}>
          {app.application}
        </div>
      </SidebarItem>
    </>
  );
}

export function ApplicationColumn() {
  const state = useGlobalState();
  const applications = state.entity?.applications;

  if (applications == undefined || applications == null) {
    return (
      <SidebarItem>
        {" "}
        <div className="no_apps">No Applications</div>{" "}
      </SidebarItem>
    );
  }

  return (
    <>
      <div className="app_col">
        {/* Title */}
        <div className="col_title_text">
          <p className="">Applications</p>
        </div>

        {/* Application Items List */}
        {applications.map((app, idx) => (
          <ApplicationItem
            key={app.application}
            app={app}
            selectedApp={state.selectedApplication}
          ></ApplicationItem>
        ))}
      </div>
    </>
  );
}

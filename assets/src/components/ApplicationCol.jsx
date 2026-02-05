"use client";

import {
  GridList,
  GridListHeader,
  GridListItem,
  GridListLabel,
  GridListSection,
  GridListStart,
} from "@/components/ui/grid-list";

import { useGlobalState, useGlobalDispatch } from "../ctx/globalContext.jsx";

import { SidebarItem } from "./CustomSidebar.jsx";

function ApplicationItem({ app, selectedApp }) {
  const dispatch = useGlobalDispatch();
  let selectApplication = () => {
    dispatch({ type: "selectApplication", application: app });
  };

  const isSelected = app == selectedApp;
  const className = isSelected ? "selected-app" : "";
  return (
    <>
      <GridListItem
        key={app.key}
        id={app.id}
        textValue={app.application}
        isSelected={app.application == selectedApp}
        onClick={selectApplication}
        className="sm:items-center"
      >
        <GridListStart className="sm:items-center">
          <div className="flex flex-col gap-x-2 sm:flex-row sm:items-center">
            <GridListLabel>{app.application}</GridListLabel>
          </div>
        </GridListStart>
      </GridListItem>
    </>
  );
}

export function ApplicationColumn() {
  const state = useGlobalState();
  // wrapping in an array to use the Section view from IntentUI gridList
  const applications = [
    {
      id: "apps-global",
      key: "apps-global",
      items: state.entity?.applications.map((app, index) => {
        return {
          id: `apps-${index}`,
          key: `apps-${index}`,
          ...app,
        };
      }),
    },
  ];

  if (applications[0].items == undefined || applications[0].items == null) {
    return (
      <SidebarItem>
        {" "}
        <div className="no_apps">No Applications</div>{" "}
      </SidebarItem>
    );
  }

  return (
    <GridList
      aria-label="Applications"
      selectionMode="single"
      items={applications}
    >
      {(appGlobal) => (
        // Title
        <GridListSection id="applications">
          <GridListHeader>
            <div>Applications</div>
          </GridListHeader>

          {appGlobal.items.map((item) => (
            // List Items
            <ApplicationItem
              key={item.id}
              app={item}
              selectedApp={state.selectedApplication}
            ></ApplicationItem>
          ))}
        </GridListSection>
      )}
    </GridList>
  );
}

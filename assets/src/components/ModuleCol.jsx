"use client";

import {
  GridList,
  GridListHeader,
  GridListItem,
  GridListLabel,
  GridListSection,
  GridListSpacer,
  GridListStart,
} from "@/components/ui/grid-list";

import { useGlobalState, useGlobalDispatch } from "../ctx/globalContext.jsx";

import { SidebarItem } from "./CustomSidebar.jsx";

import { moduleHasDocumentation } from "../helpers/stateHelper.js";
import { DocumentationIcon } from "./DocumentationIcon.jsx";

function ModuleItem({ module, selectedModule }) {
  const dispatch = useGlobalDispatch();
  let selectModule = () => {
    dispatch({ type: "selectModule", module: module });
  };
  const isSelected = module == selectedModule;
  const className = "text-sm w-auto " + (isSelected ? "selected-module" : "");

  return (
    <>
      <GridListItem
        key={module.key}
        id={module.id}
        textValue={module.module}
        isSelected={module == selectedModule}
        onClick={selectModule}
        className="sm:items-center"
      >
        <GridListStart className="sm:items-center">
          <div className="flex flex-col gap-x-2 sm:flex-row sm:items-center">
            <GridListLabel>{module.module}</GridListLabel>
          </div>
        </GridListStart>
        <GridListSpacer />
        {moduleHasDocumentation(module) ? (
          <DocumentationIcon module={module}></DocumentationIcon>
        ) : (
          <></>
        )}
      </GridListItem>
    </>
  );
}

export function ModuleColumn() {
  const state = useGlobalState();
  const app = state.selectedApplication;

  if (app.modules == undefined || app.modules == null) {
    return (
      <SidebarItem>
        <div className="no_modules">No Modules</div>
      </SidebarItem>
    );
  }

  // wrapping in an array to use the Section view from IntentUI gridList
  const modules = [
    {
      id: "modules-global",
      key: "modules-global",
      items: app.modules.map((mod, index) => {
        return {
          id: `module-${index}`,
          key: `module-${index}`,
          ...mod,
        };
      }),
    },
  ];

  return (
    <>
      <GridList aria-label="Modules" selectionMode="single" items={modules}>
        {(modGlobal) => (
          // Title
          <GridListSection id="applications">
            <GridListHeader>
              <div>Modules</div>
            </GridListHeader>

            {modGlobal.items.map((item) => (
              // List Items
              <ModuleItem
                key={item.id}
                module={item}
                selectedModule={state.selectModule}
              ></ModuleItem>
            ))}
          </GridListSection>
        )}
      </GridList>
    </>
  );
}

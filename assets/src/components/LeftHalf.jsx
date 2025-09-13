import { Sidebar, SidebarItemGroup, SidebarItems } from "flowbite-react";
import { MethodColumn } from "./MethodCol.jsx";
import { IrisTitle } from "./IrisTitle.jsx";
import { ApplicationColumn } from "./ApplicationCol.jsx";
import { ModuleColumn } from "./ModuleCol.jsx";

export function LeftHalf() {
  return (
    <>
      <div className="left_half flex flex-row items-center">
        {/*
        TITLE
        APPLICATIONS
        MODULES
         */}

        <Sidebar aria-label="Sidebar with apps and modules" className="sidebar">
          <SidebarItems>
            {/* IRIS TITLE */}
            <SidebarItemGroup>
              <IrisTitle></IrisTitle>
            </SidebarItemGroup>
            {/* Applications Column */}
            <SidebarItemGroup>
              <ApplicationColumn></ApplicationColumn>
            </SidebarItemGroup>
            {/* Modules Column */}
            <SidebarItemGroup>
              <ModuleColumn></ModuleColumn>
            </SidebarItemGroup>
          </SidebarItems>
        </Sidebar>

        {/*
        VERTICAL BORDER
         */}
        <div className="vertical-separator">
          <div className="child"></div>
        </div>

        {/*
        METHODS
         */}
        <Sidebar aria-label="sidebar with methods" className="sidebar">
          <SidebarItems>
            <SidebarItemGroup>
              <MethodColumn></MethodColumn>
            </SidebarItemGroup>
          </SidebarItems>
        </Sidebar>
      </div>
    </>
  );
}

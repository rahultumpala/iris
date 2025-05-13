import { Sidebar, SidebarItemGroup, SidebarItems } from "flowbite-react";
import { MethodColumn } from "./MethodCol.jsx";
import { IrisTitle } from "./IrisTitle.jsx";
import { ApplicationColumn } from "./ApplicationCol.jsx";
import { ModuleColumn } from "./ModuleCol.jsx";

export function LeftHalf() {
  return (
    <>
      <div className="left_half flex flex-row">
        <div className="sidebar">
          <Sidebar
            aria-label="Sidebar with apps and modules"
            className="w-auto"
          >
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
        </div>
        <Sidebar aria-label="sidebar with methods" className="methods-sidebar">
          <SidebarItems>
            <MethodColumn></MethodColumn>
          </SidebarItems>
        </Sidebar>
      </div>
    </>
  );
}

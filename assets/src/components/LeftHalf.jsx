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
          <Sidebar aria-label="Sidebar with content separator example">
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
        <MethodColumn></MethodColumn>
      </div>
    </>
  );
}

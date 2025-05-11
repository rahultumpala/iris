import {
  Sidebar,
  SidebarItem,
  SidebarItemGroup,
  SidebarItems,
} from "flowbite-react";

export function SidebarComponent() {
  return (
    <Sidebar aria-label="Sidebar with content separator example">
      <SidebarItems>
        <SidebarItemGroup>
          <SidebarItem href="#">Dashboard</SidebarItem>
          <SidebarItem href="#">Kanban</SidebarItem>
          <SidebarItem href="#">Inbox</SidebarItem>
          <SidebarItem href="#">Users</SidebarItem>
          <SidebarItem href="#">Products</SidebarItem>
          <SidebarItem href="#">Sign In</SidebarItem>
          <SidebarItem href="#">Sign Up</SidebarItem>
        </SidebarItemGroup>
        <SidebarItemGroup>
          <SidebarItem href="#">Upgrade to Pro</SidebarItem>
          <SidebarItem href="#">Documentation</SidebarItem>
          <SidebarItem href="#">Help</SidebarItem>
        </SidebarItemGroup>
      </SidebarItems>
    </Sidebar>
  );
}

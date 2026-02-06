export function Sidebar({ children }) {
    return (<>
        <div className="sidebar h-full w-64 flex flex-col pl-2 pt-2 pb-2 pr-0">
            {children}
        </div>
    </>);
}

export function SidebarItem({ children }) {
    return (<>
        <div className="sidebar-item p-2 bg-pink">
            {children}
        </div>
    </>);
}

export function SidebarItemGroup({ children }) {
    return (<>
        <div className="sidebar-item-group p-2">
            {children}
        </div>
    </>);
}
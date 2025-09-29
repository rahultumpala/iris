import { useMemo } from "react";
import {
  ReactFlow,
  Controls,
  Background,
  useNodesState,
  useEdgesState,
  useReactFlow,
} from "@xyflow/react";
import "@xyflow/react/dist/style.css";

import { useGlobalState, useGlobalDispatch } from "../ctx/globalContext.jsx";
import { nodeTypes, alignNodesWithDirection } from "./Node.jsx";
import { LayoutPanel } from "./LayoutPanel.jsx";
import { Documentation } from "./Documentation.jsx";
import {
  generateFlow,
  getLayoutedElements,
  handleExpansionToggle,
} from "../helpers/flowHelper.js";
import { isCallerNode } from "../helpers/nodeHelper.js";

export function Flow() {
  // layout related
  const reactFlow = useReactFlow();
  const [nodes, setNodes, onNodesChange] = useNodesState([]);
  const [edges, setEdges, onEdgesChange] = useEdgesState([]);

  const state = useGlobalState();
  const globalDispatch = useGlobalDispatch();
  const module = state.selectedModule;
  const method = state.selectedMethod;
  const flowDirection = state.flowDirection;
  const pathExpansionToggleNode = state.togglePathExpansion;

  const layoutTrigger = (direction, new_nodes, new_edges) => {
    const layouted = getLayoutedElements(
      new_nodes ? new_nodes : nodes,
      new_edges ? new_edges : edges,
      { direction }
    );
    new_nodes = alignNodesWithDirection([...layouted.nodes], direction);
    setNodes(new_nodes);
    setEdges([...layouted.edges]);
  };

  // React JS sorcery to update [nodes] when [gen_nodes] changes and re-render correctly AFTER first render
  useMemo(() => {
    if (module == null || method == null) {
      setNodes([]);
      setEdges([]);
      return;
    }
    const { gen_nodes, gen_edges } = generateFlow(module, method);
    layoutTrigger(flowDirection, gen_nodes, gen_edges);
  }, [module, method, flowDirection]);

  // Append to OR Delete from [nodes], [edges] the out calls generated from toggled method.
  useMemo(() => {
    // do Nothing if toggleNode is undefined -- this is the case during init.
    if (
      pathExpansionToggleNode.module == undefined ||
      pathExpansionToggleNode.method == undefined ||
      pathExpansionToggleNode.node == undefined ||
      // disallow expansion of caller nodes as they could alter methodnode as well.
      isCallerNode(pathExpansionToggleNode.node)
    )
      return;

    const { gen_nodes, gen_edges } = handleExpansionToggle(
      nodes,
      edges,
      pathExpansionToggleNode
    );

    setNodes(gen_nodes);
    setEdges(gen_edges);
    layoutTrigger(flowDirection, gen_nodes, gen_edges);

    setTimeout(() => {
      reactFlow.fitView({
        nodes: [{ id: pathExpansionToggleNode.node.data.displayName }],
        duration: 250,
        includeHiddenNodes: true,
      });
    }, 100);
  }, [pathExpansionToggleNode]);

  const togglePathExpansion = (_event, node) => {
    // _event is React.MouseEvent
    if (node.data.call.isSelectedMethod || !node.data.call.clickable) {
      // Do not toggle expansion as method is already selected.
      return;
    }
    globalDispatch({
      type: "togglePathExpansion",
      toggleNode: node,
    });
  };

  return (
    <div className="flow grid">
      <Documentation></Documentation>
      <ReactFlow
        nodes={nodes}
        edges={edges}
        nodeTypes={nodeTypes()}
        onNodesChange={() => {
          reactFlow.fitView();
          return onNodesChange;
        }}
        onEdgesChange={onEdgesChange}
        onNodeClick={togglePathExpansion}
        fitView={true}
        onInit={() => {
          reactFlow.fitView();
        }}
      >
        <LayoutPanel onLayout={layoutTrigger}></LayoutPanel>
        <Background />
        <Controls />
      </ReactFlow>
    </div>
  );
}

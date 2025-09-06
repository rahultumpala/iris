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

import { useGlobalState } from "../ctx/globalContext.jsx";
import { nodeTypes, alignNodesWithDirection } from "./Node.jsx";
import { LayoutPanel } from "./LayoutPanel.jsx";
import { Documentation } from "./Documentation.jsx";
import {
  generateFlow,
  getLayoutedElements,
  get_calls,
} from "../helpers/flowHelper.js";

export function Flow() {
  // layout related
  const reactFlow = useReactFlow();
  const [nodes, setNodes, onNodesChange] = useNodesState([]);
  const [edges, setEdges, onEdgesChange] = useEdgesState([]);
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

  const state = useGlobalState();
  const module = state.selectedModule;
  const method = state.selectedMethod;
  const flowDirection = state.flowDirection;

  // React JS sorcery to update [nodes] when [gen_nodes] changes and re-render correctly AFTER first render
  useMemo(() => {
    if (module == null || method == null) {
      setNodes([]);
      setEdges([]);
      return;
    }
    const in_calls = get_calls(module, module.in_calls, method);
    const out_calls = get_calls(module, module.out_calls, method);
    const { gen_nodes, gen_edges } = generateFlow(in_calls, method, out_calls);
    layoutTrigger(flowDirection, gen_nodes, gen_edges);
  }, [module, method, flowDirection]);
  // layout related

  return (
    <div className="flow">
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

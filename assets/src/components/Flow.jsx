import { useMemo } from "react";
import Dagre from "@dagrejs/dagre";
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
import {
  nodeTypes,
  alignNodesWithDirection,
  getDagreGraphDirection,
} from "./Node.jsx";
import { LayoutPanel } from "./LayoutPanel.jsx";
import { GlobalConstants } from "../constants.js";

import { Documentation } from "./Documentation.jsx";

/*
--------------------------------------
Generating nodes and edges from calls
*/

function generate_method_display_name(method) {
  return `${method.module}.${method.name}/${method.arity}`;
}

function generate_node(method, node_type) {
  const name = generate_method_display_name(method);
  return {
    id: name,
    data: {
      displayName: name,
      type: method.html_type_text,
      method,
    },
    type: node_type, // not to be confused with method type
  };
}

function get_calls(module, calls, method) {
  const key = `${module.module}.${method.name}/${method.arity}`;
  return calls[key] == undefined ? [] : calls[key];
}

function get_edges(in_nodes, method_node, out_nodes) {
  let edges = [];
  in_nodes.forEach((node) => {
    edges.push({
      id: `${node.id}->${method_node.id}`,
      source: node.id,
      target: method_node.id,
    });
  });
  out_nodes.forEach((node) => {
    edges.push({
      id: `${method_node.id}->${node.id}`,
      source: method_node.id,
      target: node.id,
    });
  });
  return edges;
}

function generateFlow(in_calls, method, out_calls) {
  const in_nodes = in_calls.map((call, idx) =>
    generate_node(call.method, GlobalConstants.CALLER_NODE_VERTICAL)
  );
  const out_nodes = out_calls.map((call, idx) =>
    generate_node(call.method, GlobalConstants.CALLEE_NODE_VERTICAL)
  );
  const method_node = generate_node(
    method,
    GlobalConstants.METHOD_NODE_VERTICAL
  );
  let nodes = [...in_nodes, method_node, ...out_nodes];
  nodes = nodes.map((node, idx, _) => {
    return { ...node, position: { x: 0, y: 100 * idx } };
  });
  const edges = get_edges(in_nodes, method_node, out_nodes);

  return {
    gen_nodes: nodes,
    gen_edges: edges,
  };
}

/*
--------------------------------------
  Layout related
*/

const getLayoutedElements = (nodes, edges, options) => {
  const g = new Dagre.graphlib.Graph().setDefaultEdgeLabel(() => ({}));
  const dir = getDagreGraphDirection(options.direction);
  g.setGraph({ rankdir: dir });

  edges.forEach((edge) => g.setEdge(edge.source, edge.target));
  nodes.forEach((node) =>
    g.setNode(node.id, {
      ...node,
      width: node.measured?.width ?? 300,
      height: node.measured?.height ?? 100,
    })
  );

  Dagre.layout(g);

  return {
    nodes: nodes.map((node) => {
      const position = g.node(node.id);
      // We are shifting the dagre node position (anchor=center center) to the top left
      // so it matches the React Flow node anchor point (top left).
      const x = position.x - (node.measured?.width ?? 0) / 2;
      const y = position.y - (node.measured?.height ?? 0) / 2;

      return { ...node, position: { x, y } };
    }),
    edges,
  };
};
/*
--------------------------------------
*/

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
  const showDocumentation = state.showDocumentation;

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

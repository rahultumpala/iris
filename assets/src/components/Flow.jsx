import { useCallback, useMemo, useEffect } from "react";
import Dagre from "@dagrejs/dagre";
import {
  ReactFlow,
  Controls,
  Background,
  Panel,
  useNodesState,
  useEdgesState,
  useReactFlow,
} from "@xyflow/react";
import "@xyflow/react/dist/style.css";

import { useGlobalState } from "../ctx/globalContext.jsx";
import { Callee, Caller, MethodNode } from "./Node.jsx";
import { Button, ButtonGroup } from "flowbite-react";

/*
--------------------------------------
Generating nodes and edges from calls
*/

function generate_method_display_name(method) {
  return `${method.module}.${method.name}/${method.arity}`;
}

function generate_node(method, type) {
  const name = generate_method_display_name(method);
  return {
    id: name,
    data: {
      displayName: name,
      type: method.html_type_text,
      method,
    },
    type,
  };
}

function get_calls(module, calls, method) {
  const key = `${module.module}.${method.name}`;
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
    generate_node(call.method, "caller")
  );
  const out_nodes = out_calls.map((call, idx) =>
    generate_node(call.method, "callee")
  );
  const method_node = generate_node(method, "methodNode");
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

function LayoutPanel({ onLayout }) {
  return (
    <Panel position="top-right">
      <ButtonGroup>
        <Button
          color="alternative"
          className="text-sm"
          onClick={() => onLayout("TB")}
        >
          vertical layout
        </Button>
        <Button color="alternative" onClick={() => onLayout("LR")}>
          horizontal layout
        </Button>
      </ButtonGroup>
    </Panel>
  );
}

const getLayoutedElements = (nodes, edges, options) => {
  const g = new Dagre.graphlib.Graph().setDefaultEdgeLabel(() => ({}));
  g.setGraph({ rankdir: options.direction });

  edges.forEach((edge) => g.setEdge(edge.source, edge.target));
  nodes.forEach((node) =>
    g.setNode(node.id, {
      ...node,
      width: node.measured?.width ?? 0,
      height: node.measured?.height ?? 0,
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
  const nodeTypes = {
    caller: Caller,
    callee: Callee,
    methodNode: MethodNode,
  };
  // layout related
  const { fitView } = useReactFlow();
  const [nodes, setNodes, onNodesChange] = useNodesState([]);
  const [edges, setEdges, onEdgesChange] = useEdgesState([]);

  const state = useGlobalState();
  const module = state.selectedModule;
  const method = state.selectedMethod;

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
    setNodes(gen_nodes);
    setEdges(gen_edges);
  }, [module, method]);
  useEffect(() => {
    fitView();
  }, [module, method]);
  // layout related

  const onLayout = useCallback(
    (direction) => {
      const layouted = getLayoutedElements(nodes, edges, { direction });
      setNodes([...layouted.nodes]);
      setEdges([...layouted.edges]);
      fitView();
    },
    [nodes, edges]
  );
  return (
    <div className="flow">
      <ReactFlow
        nodes={nodes}
        edges={edges}
        nodeTypes={nodeTypes}
        onNodesChange={onNodesChange}
        onEdgesChange={onEdgesChange}
        fitView={fitView}
      >
        <LayoutPanel onLayout={onLayout}></LayoutPanel>
        <Background />
        <Controls />
      </ReactFlow>
    </div>
  );
}

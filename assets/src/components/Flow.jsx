import { useRef, useLayoutEffect, useState } from "react";
import { ReactFlow, Controls, Background } from "@xyflow/react";
import "@xyflow/react/dist/style.css";

import { useGlobalState } from "../ctx/globalContext.jsx";
import { Callee, Caller, MethodNode } from "./Node.jsx";

function get_x_space(in_calls, method, out_calls) {
  let len = 0;
  in_calls.forEach((call) => {
    len = Math.max(len, generate_method_display_name(call.method).length);
  });
  out_calls.forEach((call) => {
    len = Math.max(len, generate_method_display_name(call.method).length);
  });
  len = Math.max(len, generate_method_display_name(method).length);
  return len * 9;
}

function generate_method_display_name(method) {
  return `${method.module}.${method.name}/${method.arity}`;
}

function generateFlow(in_calls, method, out_calls, { height, width }) {
  let in_nodes = in_calls.map((call, idx) => generate_node(call.method));
  let out_nodes = out_calls.map((call, idx) => generate_node(call.method));

  const start_x = 20;
  const start_y = height / 2;
  const y_space = 100;
  const x_space = get_x_space(in_calls, method, out_calls);

  const in_mid = Math.floor(in_nodes.length / 2);
  in_nodes = in_nodes.map((node, idx) => {
    const in_y = start_y - (in_mid - idx) * y_space;
    return {
      ...node,
      position: {
        x: start_x,
        y: in_y,
      },
      type: "caller",
    };
  });

  let method_node = {
    ...generate_node(method),
    position: { x: start_x + x_space, y: start_y },
    type: "methodNode",
  };

  const out_mid = Math.floor(out_nodes.length / 2);
  out_nodes = out_nodes.map((node, idx) => {
    const out_y = start_y - (out_mid - idx) * y_space;
    return {
      ...node,
      position: {
        x: start_x + 2 * x_space,
        y: out_y,
      },
      type: "callee",
    };
  });

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

  let nodes = [...in_nodes, method_node, ...out_nodes];
  console.log(nodes);
  return {
    nodes: nodes,
    edges: edges,
  };
}

function generate_node(method) {
  const name = generate_method_display_name(method);
  return {
    id: name,
    data: {
      displayName: name,
      type: method.html_type_text,
      method,
    },
    position: {
      x: 0,
      y: 0,
    },
  };
}

function get_calls(module, calls, method) {
  const key = `${module.module}.${method.name}`;
  return calls[key] == undefined ? [] : calls[key];
}

function emptyGraph(ref, nodeTypes) {
  return (
    <div className="flow">
      <ReactFlow ref={ref} nodes={[]} edges={[]} nodeTypes={nodeTypes}>
        <Background />
        <Controls />
      </ReactFlow>
    </div>
  );
}

export function Flow() {
  const nodeTypes = {
    caller: Caller,
    callee: Callee,
    methodNode: MethodNode,
  };

  // To be able to use the container height in calculating position of nodes
  const ref = useRef(null);
  const [divMeasurements, setDivMeasurements] = useState({});

  useLayoutEffect(() => {
    const { height, width } = ref.current.getBoundingClientRect();
    setDivMeasurements({ height, width });
  }, []);

  const state = useGlobalState();
  const module = state.selectedModule;
  const method = state.selectedMethod;

  if (module == null || method == null) return emptyGraph(ref, nodeTypes);

  const in_calls = get_calls(module, module.in_calls, method);
  const out_calls = get_calls(module, module.out_calls, method);

  const flow = generateFlow(in_calls, method, out_calls, divMeasurements);

  return (
    <div className="flow" ref={ref}>
      <ReactFlow nodes={flow.nodes} edges={flow.edges} nodeTypes={nodeTypes}>
        <Background />
        <Controls />
      </ReactFlow>
    </div>
  );
}

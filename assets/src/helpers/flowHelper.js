import Dagre from "@dagrejs/dagre";
import { GlobalConstants } from "../constants.js";
import {
    getDagreGraphDirection,
} from "../components/Node.jsx";

/*
--------------------------------------
Generating nodes and edges from calls
*/

function generate_method_display_name(method) {
    return `${method.module}.${method.name}/${method.arity}`;
}

function generate_node(call, node_type) {
    const name = generate_method_display_name(call.method);
    return {
        id: name,
        data: {
            displayName: name,
            type: call.method.html_type_text,
            call,
            isSelectedMethod: call.isSelectedMethod
        },
        type: node_type, // not to be confused with method type
    };
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

export function get_calls(module, calls, method) {
    const key = `${module.module}.${method.name}/${method.arity}`;
    return calls[key] == undefined ? [] : calls[key];
}

export function generateFlow(in_calls, method, out_calls) {
    const in_nodes = in_calls.map((call, idx) =>
        generate_node(call, GlobalConstants.CALLER_NODE_VERTICAL)
    );
    const out_nodes = out_calls.map((call, idx) =>
        generate_node(call, GlobalConstants.CALLEE_NODE_VERTICAL)
    );

    // wrapping inside object.method to allow support for call objects
    // setting [isSelectedMethod] to disallow node click actions
    const method_node = generate_node(
        { method, isSelectedMethod: true },
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

export function getLayoutedElements(nodes, edges, options) {
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

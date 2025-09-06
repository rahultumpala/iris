import Dagre from "@dagrejs/dagre";
import { GlobalConstants } from "../constants.js";
import {
    getDagreGraphDirection,
} from "../components/Node.jsx";

/*
--------------------------------------
Generating nodes and edges from calls
*/

function generate_node(call, node_type) {
    const name = generate_method_display_name(call.method);
    return {
        id: name,
        data: {
            displayName: name,
            type: call.method.html_type_text,
            call,
            isSelectedMethod: call.isSelectedMethod,
            isExpanded: false, // set to false by default - will be toggled if [toggleExpansionPath] is invoked.
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

function get_calls(module, calls, method) {
    const key = `${module.module}.${method.name}/${method.arity}`;
    return calls[key] == undefined ? [] : calls[key];
}

export function generate_method_display_name(method) {
    return `${method.module}.${method.name}/${method.arity}`;
}

export function generateFlow(module, method) {
    const in_calls = get_calls(module, module.in_calls, method);
    const out_calls = get_calls(module, module.out_calls, method);

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

export function handleExpansionToggle(cur_nodes, cur_edges, toggleData) {

    console.log("TOGGLE DATA", toggleData, cur_nodes, cur_edges);

    const toggleMethod = toggleData.method;
    const toggleModule = toggleData.module;
    const toggleNodeData = toggleData.nodeData;
    const toggleNode = cur_nodes.filter(node => node.data == toggleNodeData)[0];

    const isAlreadyExpanded = toggleNodeData.isExpanded;
    console.log("isAlreadyExpanded", isAlreadyExpanded);

    const out_calls = get_calls(toggleModule, toggleModule.out_calls, toggleMethod);
    const out_nodes = out_calls.map((call, idx) =>
        generate_node(call, GlobalConstants.CALLEE_NODE_VERTICAL)
    );
    const out_edges = get_edges([], toggleNode, out_nodes);

    /*
     If already expanded then delete all out_edges and out_nodes emanating from toggleNode
     Take care not to delete nodes that have more than one incoming edge

     Else append out_nodes and out_edges to cur_nodes and cur_edges

     toggle [isExpanded] field
     */

    if (isAlreadyExpanded) {
        // group nodes by incoming edges.
        const incomingEdges = out_edges.reduce((accMap, edge) => {
            accMap[edge.target] = (accMap[edge.target] || 0) + 1;
            return accMap;
        }, {});
        // add only those nodes from [out_nodes] that have only 1 incoming edge
        // accumulate into a map
        const delNodes = out_nodes.filter(node => incomingEdges[node.id] == 1).reduce((acc, node) => { acc[node.id] = node; return acc; }, {});
        const delEdges = out_edges.reduce((acc, edge) => acc[edge.id] = edge, {});

        cur_nodes = cur_nodes.filter(node => delNodes[node.id] == undefined); // filter those that are not deleted.
        cur_edges = cur_edges.filter(edge => delEdges[edge.id] == undefined); // filter those that are not deleted.
    } else {
        cur_nodes = cur_nodes.concat(out_nodes);
        cur_edges = cur_edges.concat(out_edges);
    }

    // Toggle
    cur_nodes = cur_nodes.map(node => {
        if (node == toggleNode) {
            return {
                ...node,
                data: {
                    ...node.data,
                    isExpanded: !isAlreadyExpanded,
                },
                type: isAlreadyExpanded ? GlobalConstants.CALLEE_NODE_VERTICAL : GlobalConstants.METHOD_NODE_VERTICAL
            };
        }
        return node;
    });
    cur_nodes = cur_nodes.map((node, idx, _) => {
        return { ...node, position: { x: 0, y: 100 * idx } };
    });

    console.log("RETURN DATA", toggleData, cur_nodes, cur_edges);

    return {
        gen_nodes: cur_nodes,
        gen_edges: cur_edges
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

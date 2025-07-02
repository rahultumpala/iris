import { Handle, Position } from "@xyflow/react";
import { GlobalConstants } from "../constants";

function Node({ data }) {
  return (
    <>
      <div className="node text-sm">{data.displayName}</div>
    </>
  );
}

function SourceHandle({ dir }) {
  switch (dir) {
    case "H": {
      return (
        <Handle type="source" position={Position.Right} isConnectable={true} />
      );
    }
    case "V": {
      return (
        <Handle type="source" position={Position.Bottom} isConnectable={true} />
      );
    }
  }
}

function TargetHandle(dir) {
  switch (dir) {
    case "H": {
      return (
        <Handle type="target" position={Position.Left} isConnectable={true} />
      );
    }
    case "V": {
      return (
        <Handle type="target" position={Position.Top} isConnectable={true} />
      );
    }
  }
}

export function Caller_H({ data }) {
  return (
    <>
      <SourceHandle dir={"H"}></SourceHandle>
      <Node data={data}></Node>
    </>
  );
}
export function Caller_V({ data }) {
  return (
    <>
      <Node data={data}></Node>
      <SourceHandle dir={"V"}></SourceHandle>
    </>
  );
}

export function Callee_H({ data }) {
  return (
    <>
      <TargetHandle dir={"H"}></TargetHandle>
      <Node data={data}></Node>
    </>
  );
}

export function Callee_V({ data }) {
  return (
    <>
      <TargetHandle dir={"V"}></TargetHandle>
      <Node data={data}></Node>
    </>
  );
}

function MethodNode({ dir, data }) {
  return (
    <>
      <TargetHandle dir={dir}> </TargetHandle>
      <Node data={data}></Node>
      <SourceHandle dir={dir}> </SourceHandle>
    </>
  );
}

function Method_H({ data }) {
  return <MethodNode dir={"H"} data={data} />;
}
function Method_V({ data }) {
  return <MethodNode dir={"V"} data={data} />;
}

export function alignNodesWithDirection(nodes) {
  return nodes.map((node) => {
    return {
      ...node,
      type: toggleNodeType(node.type),
    };
  });
}

export function nodeTypes() {
  return {
    caller_v: Caller_V,
    caller_h: Caller_H,
    callee_v: Callee_V,
    callee_h: Callee_H,
    method_node_v: Method_V,
    method_node_h: Method_H,
  };
}

export function toggleDagreGraphDirection(dir) {
  switch (dir) {
    case "H": {
      return "TB";
    }
    case "V": {
      return "LR";
    }
  }
}

function toggleNodeType(type) {
  switch (type) {
    case GlobalConstants.CALLEE_NODE_HORIZONTAL: {
      return GlobalConstants.CALLEE_NODE_VERTICAL;
    }
    case GlobalConstants.CALLEE_NODE_VERTICAL: {
      return GlobalConstants.CALLEE_NODE_HORIZONTAL;
    }
    case GlobalConstants.CALLER_NODE_HORIZONTAL: {
      return GlobalConstants.CALLER_NODE_VERTICAL;
    }
    case GlobalConstants.CALLER_NODE_VERTICAL: {
      return GlobalConstants.CALLER_NODE_HORIZONTAL;
    }
    case GlobalConstants.METHOD_NODE_HORIZONTAL: {
      return GlobalConstants.METHOD_NODE_VERTICAL;
    }
    case GlobalConstants.METHOD_NODE_VERTICAL: {
      return GlobalConstants.METHOD_NODE_HORIZONTAL;
    }
  }
}

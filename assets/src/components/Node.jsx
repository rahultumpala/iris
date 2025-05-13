import { Handle, Position } from "@xyflow/react";

function Node({ data }) {
  return (
    <>
      <div className="node">{data.displayName}</div>
    </>
  );
}

export function Caller({ data }) {
  return (
    <>
      <Handle type="source" position={Position.Right} isConnectable={true} />
      <Node data={data}></Node>
    </>
  );
}

export function Callee({ data }) {
  return (
    <>
      <Handle type="target" position={Position.Left} isConnectable={true} />
      <Node data={data}></Node>
    </>
  );
}

export function MethodNode({ data }) {
  return (
    <>
      <Handle type="target" position={Position.Left} isConnectable={true} />
      <Node data={data}></Node>
      <Handle type="source" position={Position.Right} isConnectable={true} />
    </>
  );
}

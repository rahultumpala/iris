import { Handle, Position } from "@xyflow/react";
import { GlobalConstants } from "../constants";
import { RecursionIcon } from "./RecursionIcon";
import { methodHasDocumentation } from "../helpers/stateHelper";
import { DocumentationIcon } from "./DocumentationIcon";

function Node({ data }) {
  const method = data.call.method;
  const clickable = data.call.clickable;
  const isCurrentlySelectedMethod = data.isSelectedMethod;
  const className = `node-base text-sm ${
    !clickable && !isCurrentlySelectedMethod ? "not-clickable-method-node" : ""
  }`;
  return (
    <>
      <div className={className}>
        <div className="name">{data.displayName}</div>
        {method.is_recursive ? <RecursionIcon></RecursionIcon> : <></>}
        {methodHasDocumentation(method) ? (
          <DocumentationIcon method={method}></DocumentationIcon>
        ) : (
          <></>
        )}
      </div>
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

function TargetHandle({ dir }) {
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

export function alignNodesWithDirection(nodes, dir) {
  return nodes.map((node) => {
    return {
      ...node,
      type: getNodeType(node.type, dir),
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

export function getDagreGraphDirection(dir) {
  switch (dir) {
    case "V": {
      return "TB";
    }
    case "H": {
      return "LR";
    }
  }
}

function getNodeType(type, dir) {
  switch (type) {
    case GlobalConstants.CALLER_NODE_HORIZONTAL:
    case GlobalConstants.CALLER_NODE_VERTICAL:
      return dir == "H"
        ? GlobalConstants.CALLER_NODE_HORIZONTAL
        : GlobalConstants.CALLER_NODE_VERTICAL;
    case GlobalConstants.CALLEE_NODE_HORIZONTAL:
    case GlobalConstants.CALLEE_NODE_VERTICAL:
      return dir == "H"
        ? GlobalConstants.CALLEE_NODE_HORIZONTAL
        : GlobalConstants.CALLEE_NODE_VERTICAL;
    case GlobalConstants.METHOD_NODE_HORIZONTAL:
    case GlobalConstants.METHOD_NODE_VERTICAL:
      return dir == "H"
        ? GlobalConstants.METHOD_NODE_HORIZONTAL
        : GlobalConstants.METHOD_NODE_VERTICAL;
  }
}

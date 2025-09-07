import { GlobalConstants } from "../constants";

export function isCallerNode(node) {
    return (node.type == GlobalConstants.CALLER_NODE_HORIZONTAL)
        || (node.type == GlobalConstants.CALLER_NODE_VERTICAL);
}
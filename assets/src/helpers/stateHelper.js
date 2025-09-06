import { generate_method_display_name } from "./flowHelper.js";

/*
NodeData contains the call object.
Fetch the associated [module] and method object from [globalState]
[out_calls] can be fetched from [module]
*/
export function getTogglePathExpansionDetails(allModules, nodeData) {
    const nodeModule = nodeData.call.method.module;
    const nodeDisplayName = nodeData.displayName;

    const module = allModules.filter(m => m.module == nodeModule)[0];

    const allMethods = allModules.reduce((acc, module) => acc.concat(module.methods), []);
    const method = allMethods.filter(m => generate_method_display_name(m) === nodeDisplayName)[0];

    // this is to be stored in [togglePathExpansion] in [globalState]
    return {
        module,
        method,
        nodeData: nodeData
    }
}

export function getAllModules(globalState) {
    return globalState.entity.applications.reduce((allModules, app) => allModules.concat(app.modules), []);
}
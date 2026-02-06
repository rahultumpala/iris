"use client";

import {
  GridList,
  GridListHeader,
  GridListItem,
  GridListLabel,
  GridListSection,
  GridListSpacer,
  GridListStart,
} from "@/components/ui/grid-list";

import { useGlobalState, useGlobalDispatch } from "../ctx/globalContext.jsx";

import { Tooltip } from "flowbite-react";
import { SidebarItem } from "./CustomSidebar.jsx";

import { RecursionIcon } from "./RecursionIcon.jsx";
import { methodHasDocumentation } from "../helpers/stateHelper.js";
import { DocumentationIcon } from "./DocumentationIcon.jsx";
import { Heading } from "./ui/heading.jsx";
import { MacroIcon } from "./MacroIcon.jsx";
import { generate_method_display_name } from "@/helpers/flowHelper.js";

function MethodType({ text, tooltip }) {
  const attributes = {
    className: `method-type text-xs ${
      text == "INT" ? "method-type-internal" : "method-ext"
    }`,
  };

  return (
    <>
      <Tooltip
        content={tooltip}
        placement="right"
        className="text-xs font-normal bg-gray-900 "
      >
        <div {...attributes}>{text}</div>
      </Tooltip>
    </>
  );
}

function MethodItem({ method, selectedMethod }) {
  const dispatch = useGlobalDispatch();
  const selectMethod = () => {
    dispatch({
      type: "selectMethod",
      method: method,
    });
  };

  const clickable =
    method.html_type_text == "INT" || method.html_type_text == "EXP";
  const isSelected = method == selectedMethod;
  const onClick = clickable ? selectMethod : null;
  const hasDocumentation = methodHasDocumentation(method);

  return (
    <>
      <GridListItem
        key={method.key}
        id={method.id}
        textValue={`${method.name} / ${method.arity}`}
        isSelected={method == selectedMethod}
        className="sm:items-center"
        isDisabled={clickable ? false : true}
      >
        <GridListStart
          className="sm:items-center cursor-pointer"
          onClick={onClick}
        >
          <div className="flex flex-col gap-x-2 sm:flex-row sm:items-center">
            <GridListLabel>
              {method.name} / {method.arity}
            </GridListLabel>
          </div>
        </GridListStart>
        <GridListSpacer />

        {method.is_macro ? <MacroIcon></MacroIcon> : <></>}

        {hasDocumentation ? (
          <DocumentationIcon method={method}></DocumentationIcon>
        ) : (
          <></>
        )}

        {method.is_recursive ? (
          <RecursionIcon
            className={"in-method-col"}
            selectedMethod={isSelected}
          ></RecursionIcon>
        ) : (
          <></>
        )}
        <MethodType
          text={method.html_type_text}
          tooltip={method.tooltip_text}
        ></MethodType>
      </GridListItem>
    </>
  );
}

export function MethodColumn() {
  const state = useGlobalState();
  const module = state.selectedModule;
  if (
    module == undefined ||
    module == null ||
    module.methods == undefined ||
    module.methods == null
  ) {
    return (
      <SidebarItem>
        <div className="no_methods">No Functions</div>
      </SidebarItem>
    );
  }

  // wrapping in an array to use the Section view from IntentUI gridList
  const functions = [
    {
      id: "functions-global",
      key: "functions-global",
      items: module.methods.map((method, index) => {
        return {
          id: `function-${index}`,
          key: `function-${index}`,
          ...method,
        };
      }),
    },
  ];

  // to show the selected UI by default
  const selectedKeys = [
    functions[0].items.filter((f, _idx, _) => {
      const l = generate_method_display_name(f);
      const r = generate_method_display_name(state.selectedMethod);
      return l == r;
    })[0].key,
  ];

  return (
    <>
      <GridList
        aria-label="Functions"
        selectionMode="single"
        items={functions}
        selectedKeys={selectedKeys}
      >
        {(fnGlobal) => (
          // Title
          <GridListSection id="functions">
            <GridListHeader className={"pr-2"}>
              <Heading level={3}>{module.module}</Heading>
            </GridListHeader>

            {fnGlobal.items.map((item) => (
              // List Items
              <MethodItem
                key={item.id}
                method={item}
                selectedMethod={state.selectedMethod}
              ></MethodItem>
            ))}
          </GridListSection>
        )}
      </GridList>
    </>
  );
}

import { composeRenderProps } from "react-aria-components"
import { twMerge } from "tailwind-merge";

/** @deprecated Use cx */
export function composeTailwindRenderProps(className, tailwind) {
  return composeRenderProps(className, (className) => twMerge(tailwind, className));
}

export function cx(...args) {
  let resolvedArgs = args
  if (args.length === 1 && Array.isArray(args[0])) {
    resolvedArgs = args[0]
  }

  const className = resolvedArgs.pop()
  const tailwinds = resolvedArgs

  const fixed = twMerge(...tailwinds)

  return composeRenderProps(className, (cn) => twMerge(fixed, cn));
}

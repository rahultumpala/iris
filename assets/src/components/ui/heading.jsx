import { twMerge } from "tailwind-merge"

const Heading = ({
  className,
  level = 1,
  ...props
}) => {
  const Element = `h${level}`
  return (
    <Element
      className={twMerge(
        "font-sans font-semibold text-fg tracking-tight",
        level === 1 && "text-xl/8 sm:text-2xl/8",
        level === 2 && "text-lg/6 sm:text-xl/8",
        level === 3 && "text-base/6 sm:text-lg/6",
        level === 4 && "text-base/6",
        className
      )}
      {...props} />
  );
}

export { Heading }

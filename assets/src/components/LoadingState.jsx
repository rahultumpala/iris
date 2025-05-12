import { Spinner } from "flowbite-react";

export function LoadingState() {
  return (
    <>
      <div className="center h-[100vh] w-[100vw] flex flex-col justify-center items-center">
        <Spinner aria-label="Default status when state is not loaded" />
        <h2 className="m-5">Reading state...</h2>
      </div>
    </>
  );
}

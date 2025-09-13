import { GlobalConstants } from "../constants";

export function FetchFailedState() {
  return (
    <>
      <div className="center h-[100vh] w-[100vw] flex flex-col justify-center items-center">
        <h2 className="m-5">{GlobalConstants.ENTITY_FETCH_FAILED}</h2>
      </div>
    </>
  );
}

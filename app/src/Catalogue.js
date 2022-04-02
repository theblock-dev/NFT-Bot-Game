import React from "react";
import { drizzleReactHooks } from "@drizzle/react-plugin";
import { newContextComponents } from "@drizzle/react-components";
import KittyList from "./KittyList.js";

const { useDrizzle, useDrizzleState } = drizzleReactHooks;
const { ContractData } = newContextComponents;

export default () => {
  const { drizzle } = useDrizzle();
  const state = useDrizzleState(state => state);

  return (
    <div>
      <div>
        <h2>Catalog of All Robots</h2>
        <ContractData
          drizzle={drizzle}
          drizzleState={state}
          contract="CryptoKittens"
          method="tokenBaseURI"
          render={uriBase => {
            return (
              <ContractData
                drizzle={drizzle}
                drizzleState={state}
                contract="CryptoKittens"
                method="getAllKitties"
                render={kitties => (
                  <KittyList 
                    kitties={kitties} 
                    uriBase={uriBase}
                  /> 
                )}
              />
            );
          }}
        />
      </div>
    </div>
  );
};
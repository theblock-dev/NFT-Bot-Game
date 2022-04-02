import React from "react";
import { drizzleReactHooks } from "@drizzle/react-plugin";
import { newContextComponents } from "@drizzle/react-components";
import KittyList from "./KittyList.js";

const { useDrizzle, useDrizzleState } = drizzleReactHooks;
const { ContractForm, ContractData } = newContextComponents;

export default () => {
  const { drizzle } = useDrizzle();
  const state = useDrizzleState(state => state);

  return (
    <div>
      <div>
        <h2>Breed new robot by mixing 2 Bots</h2>
        <ContractForm
          drizzle={drizzle}
          contract="CryptoKittens"
          method="breed"
        />
      </div>
      <div>
        <h2>Your Robots</h2>
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
                method="getAllKittiesOf"
                methodArgs={[state.accounts[0]]}
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
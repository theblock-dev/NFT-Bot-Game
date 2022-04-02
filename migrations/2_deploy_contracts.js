const Kitties = artifacts.require("CryptoKittens.sol");

module.exports = async function(deployer, network, accounts){
   await deployer.deploy(Kitties,"SCK", "SAM CryptoKitties", "https://robohash.org", {from:accounts[0]});

    const kittyInstance = await Kitties.deployed();

    await Promise.all([ 
        kittyInstance.mint(),
        kittyInstance.mint(),
        kittyInstance.mint(),
        kittyInstance.mint()
    ]);
}
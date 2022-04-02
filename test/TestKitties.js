const CryptoKittens = artifacts.require("CryptoKittens.sol");
const { expectRevert } = require('@openzeppelin/test-helpers');


contract("CryptoKittens", (accounts)=>{
    let kittyInstance = undefined;
    const [admin, player1, player2, _] = accounts;

    beforeEach(async()=>{
        kittyInstance = await CryptoKittens.deployed();
    });

    it("should not mint if not admin", async()=>{
        await expectRevert(
            kittyInstance.mint({from:player1}),
            "only admin can mint"
        );
    });

    it("should mint new kitties by admin", async()=>{
        await kittyInstance.mint({from:admin});
        await kittyInstance.mint({from:admin});
        
        const owner0 = await kittyInstance.ownerOf(0);
        const owner1 = await kittyInstance.ownerOf(1);
        assert(owner0 === admin);

        const nextId = await kittyInstance.nextId();
        assert(nextId.toNumber() === 2);

        const kitty1 = await kittyInstance._kitties(0);
        assert(kitty1.id.toNumber() === 0);
        assert(kitty1.generation.toNumber() === 1);
    });

    it("should breed new kitty", async()=>{
        await kittyInstance.mint();
        await kittyInstance.mint();
        await kittyInstance.breed(2,3);

        const nextId = await kittyInstance.nextId();
        console.log('nextId', nextId);
        assert(nextId.toNumber() === 5);

        const kitty3 = await kittyInstance._kitties(4)
        assert(kitty3.id.toNumber() === 4);
        //assert(kitty3.generation.toNumber() === 4 );


    })

 


});
var JubsICO = artifacts.require("./JubsICO.sol");
var SafeMath = artifacts.require("./SafeMath.sol");


module.exports = function(deployer) {
  deployer.deploy(SafeMath);
  deployer.link(SafeMath,JubsICO);
  deployer.deploy(JubsICO,
    0x06Bb03FE3F01cC5c905e45c0a439B49c972f18d6,
    0xbbD1a201c25C5467ab0747d4036db9826872F0f4,
    0x2B80054C90719349e18Ffa0Aab08EC7965D858C4,
    0x6790f47552957d93A258B3B3b07bFbe4c9C99942,
    0x42A3ACc5b75Ad09c4d04e17a7eb634F554902dc7,
    0xA3DD41Ef47d7b9A436e4518BAA8F2cc0EC0CB504,
    0x8344F82ad6303D1E82CDCE5Cd20470D68cf76497,  
    0xd43B4fFc6B50eE3F31cF2E7A6CA31A839Cdb99E3,  
    0xd0C057F0EBd6025962Bb7575F8D000e3cab5Fb6d    
  );
};


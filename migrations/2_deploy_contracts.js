var JubsICO = artifacts.require("./JubsICO.sol");
var SafeMath = artifacts.require("./SafeMath.sol");


module.exports = function(deployer) {
  deployer.deploy(SafeMath);
  deployer.link(SafeMath,JubsICO);
  deployer.deploy(JubsICO,
    0x93209768ebc3b1ef5211962234f215163ff806a4,
    0xc96e3043862fb040389a7d3e3124832aa34744f4,
    0x9823d4301bd1dac097ae091b2c70136b9acccc12,
    0xadd5f3d87c22a0c9862544ce68e05b3861ff8e03,
    0x05ef09f12cb2675a66a85a900b89baa56bf9f8b8,
    0x397bdc325268bd67da787850b0a1ef3ef0d81b35,  
    0x8871bee6e02ec06b2690c96b565a9ceb0ea0d63c,  
    10000,
    60000  
  );
};


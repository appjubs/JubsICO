var JubsICO = artifacts.require("./JubsICO.sol");
var SafeMath = artifacts.require("./SafeMath.sol");

module.exports = function(deployer) {
  deployer.deploy(SafeMath);
  deployer.link(SafeMath,JubsICO);
  deployer.deploy(JubsICO,
    0x6ea3ec9339839924a520ff57a0b44211450a8910,
    0x357ace6312bf8b519424cd3ffdbb9990634b8d3e,
    0x7c54dc4f3328197ac89a53d4b8cdbe35a56656f7,
    0x06bc5305016e9972f4cb3f6a3ef2c734d417788a,
    0x6f67b977859dee77fe85cbcad5b5bd5ad58bf068,
    0xde9de3267cbd21cd64b40516fd2aaeb5d77fb001,
    0x232f7caa500dcad6598cae4d90548a009dd49e6f,
    0xa6b898b2ab02c277ae7242b244fb5fd55cafb2b7,
    0x96819778cc853488d3e37d630d94a337abd527a8
  );
};


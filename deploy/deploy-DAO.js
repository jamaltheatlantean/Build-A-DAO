const {
    network,
  } = require("hardhat");
  
  module.exports = async ({ getNamedAccounts, deployments }) => {
    const { deploy, log } = deployments;
    const { deployer } = await getNamedAccounts();
  
    const arguments = [];
    const dao = await deploy("DAO", {
      from: deployer,
      args: arguments,
      log: true,
    });
  
    const networkName = network.name == "hardhat" ? "localhost" : network.name;
    log(`npx hardhat run scripts/deploy-DAO.js --network ${networkName}`);
    log("----------------------------------------------------");
  };
  
  module.exports.tags = ["all", "dao"];
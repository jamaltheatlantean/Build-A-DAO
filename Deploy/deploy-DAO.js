const {
    getNamedAccounts,
    deployments,
    network,
    run,
    ethers,
  } = require("hardhat");
  const {
    networkConfig,
    developmentChains
  } = require("../helper-hardhat-config");
  
  
  module.exports = async ({ getNamedAccounts, deployments }) => {
    const { deploy, log } = deployments;
    const { deployer } = await getNamedAccounts();
    const chainId = network.config.chainId;
  
    const arguments = [];
    const daoContract = await deploy("DAOContract", {
      from: deployer,
      args: arguments,
      log: true,
      waitConfirmations: waitBlockConfirmations || 1,
    });
  
    const networkName = network.name == "hardhat" ? "localhost" : network.name;
    log(`npx hardhat run scripts/deploy-DAO.js --network ${networkName}`);
    log("----------------------------------------------------");
  };
  
  module.exports.tags = ["all", "daoContract"];
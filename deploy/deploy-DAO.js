const {
    getNamedAccounts,
    deployments,
    network,
    run,
    ethers,
  } = require("hardhat");
  const {
    networkConfig,
    developmentChains,
    VERIFICATION_BLOCK_CONFIRMATIONS,
  } = require("../helper-hardhat-config");
  
  const waitBlockConfirmations = developmentChains.includes(network.name)
  ? 1
  : VERIFICATION_BLOCK_CONFIRMATIONS;
  
  module.exports = async ({ getNamedAccounts, deployments }) => {
    const { deploy, log } = deployments;
    const { deployer } = await getNamedAccounts();
    const chainId = network.config.chainId;
  
    const arguments = [];
    const dao = await deploy("DAO", {
      from: deployer,
      args: arguments,
      log: true,
      waitConfirmations: waitBlockConfirmations || 1,
    });
  
    // Verify the deployment
    if (
      !developmentChains.includes(network.name) &&
      process.env.ETHERSCAN_API_KEY
    ) {
      log("Verifying...");
      await verify(dao.address, arguments);
    }
  
    const networkName = network.name == "hardhat" ? "localhost" : network.name;
    log(`npx hardhat run scripts/deploy-DAO.js --network ${networkName}`);
    log("----------------------------------------------------");
  };
  
  module.exports.tags = ["all", "dao"];
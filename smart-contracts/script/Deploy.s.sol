// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "forge-std/Script.sol";
import "../src/BlobStorage.sol";

/**
 * @title Deploy
 * @dev Deployment script for BlobStorage contract on Base Sepolia
 */
contract Deploy is Script {
    function run() external {
        // Get private key from environment
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        
        // Start broadcasting transactions
        vm.startBroadcast(deployerPrivateKey);

        // Deploy the BlobStorage contract
        BlobStorage blobStorage = new BlobStorage();
        
        console.log("BlobStorage deployed to:", address(blobStorage));
        console.log("Deployer address:", vm.addr(deployerPrivateKey));
        console.log("Transaction hash will be shown above");
        
        // Stop broadcasting
        vm.stopBroadcast();
    }
}

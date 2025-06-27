#!/bin/bash

# Deployment script for BlobStorage contract on Base Sepolia

echo "🚀 Deploying BlobStorage contract to Base Sepolia..."

# Check if PRIVATE_KEY is set
if [[ -z "$PRIVATE_KEY" ]]; then
    echo "❌ Error: PRIVATE_KEY environment variable is not set"
    echo "Please set your private key: export PRIVATE_KEY=your_private_key_here"
    exit 1
fi

# Use Base Sepolia RPC URL
RPC_URL=${SEPOLIA_RPC_URL:-"https://sepolia.base.org"}

echo "🔗 Using RPC URL: $RPC_URL"

# Deploy the contract
forge script script/Deploy.s.sol \
    --rpc-url $RPC_URL \
    --private-key $PRIVATE_KEY \
    --broadcast \
    --verify \
    --etherscan-api-key $BASESCAN_API_KEY \
    -vvvv

echo "✅ Deployment completed!"
echo "📝 Check the output above for the deployed contract address"

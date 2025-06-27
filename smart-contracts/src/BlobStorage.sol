// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

/**
 * @title BlobStorage
 * @dev A simple contract to store blob data associated with passkey-derived keys
 * @notice This contract allows storing arbitrary data blobs that can be retrieved later
 */
contract BlobStorage {
    // Events
    event BlobStored(bytes32 indexed key, address indexed sender, uint256 size);
    event BlobDeleted(bytes32 indexed key, address indexed sender);

    // Storage mapping: key => blob data
    mapping(bytes32 => bytes) private blobs;
    
    // Track blob owners for access control
    mapping(bytes32 => address) private blobOwners;
    
    // Track blob existence
    mapping(bytes32 => bool) private blobExists;

    /**
     * @dev Store a blob of data with a given key
     * @param key The key to associate with the blob (typically derived from passkey PRF)
     * @param data The blob data to store
     */
    function storeBlob(bytes32 key, bytes calldata data) external {
        require(data.length > 0, "BlobStorage: Cannot store empty blob");
        require(data.length <= 1024 * 1024, "BlobStorage: Blob too large (max 1MB)");
        
        // If blob exists, only owner can update it
        if (blobExists[key]) {
            require(blobOwners[key] == msg.sender, "BlobStorage: Only owner can update blob");
        } else {
            // First time storing, set owner
            blobOwners[key] = msg.sender;
            blobExists[key] = true;
        }
        
        blobs[key] = data;
        emit BlobStored(key, msg.sender, data.length);
    }

    /**
     * @dev Retrieve a blob by its key
     * @param key The key of the blob to retrieve
     * @return The blob data
     */
    function getBlob(bytes32 key) external view returns (bytes memory) {
        require(blobExists[key], "BlobStorage: Blob does not exist");
        return blobs[key];
    }

    /**
     * @dev Check if a blob exists for a given key
     * @param key The key to check
     * @return True if the blob exists, false otherwise
     */
    function blobExistsForKey(bytes32 key) external view returns (bool) {
        return blobExists[key];
    }

    /**
     * @dev Get the owner of a blob
     * @param key The key of the blob
     * @return The address of the blob owner
     */
    function getBlobOwner(bytes32 key) external view returns (address) {
        require(blobExists[key], "BlobStorage: Blob does not exist");
        return blobOwners[key];
    }

    /**
     * @dev Get the size of a blob
     * @param key The key of the blob
     * @return The size of the blob in bytes
     */
    function getBlobSize(bytes32 key) external view returns (uint256) {
        require(blobExists[key], "BlobStorage: Blob does not exist");
        return blobs[key].length;
    }

    /**
     * @dev Delete a blob (only owner can delete)
     * @param key The key of the blob to delete
     */
    function deleteBlob(bytes32 key) external {
        require(blobExists[key], "BlobStorage: Blob does not exist");
        require(blobOwners[key] == msg.sender, "BlobStorage: Only owner can delete blob");
        
        delete blobs[key];
        delete blobOwners[key];
        delete blobExists[key];
        
        emit BlobDeleted(key, msg.sender);
    }

    /**
     * @dev Get total number of blobs stored by an address
     * @param owner The address to check
     * @return The count of blobs owned by the address
     * @notice This is an expensive operation for large datasets
     */
    function getBlobCount(address owner) external view returns (uint256) {
        // Note: This is a simplified implementation
        // In production, you'd want to track this more efficiently
        uint256 count = 0;
        // This would require iterating through all possible keys which is not practical
        // Better to emit events and track off-chain or use a more efficient data structure
        revert("BlobStorage: Use events to track blob counts off-chain");
    }
}

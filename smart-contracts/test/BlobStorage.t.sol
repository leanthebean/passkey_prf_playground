// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "forge-std/Test.sol";
import "../src/BlobStorage.sol";

contract BlobStorageTest is Test {
    BlobStorage public blobStorage;
    
    // Test accounts
    address public owner = address(0x1);
    address public user1 = address(0x2);
    address public user2 = address(0x3);
    
    // Test data
    bytes32 public testKey1 = keccak256("test-key-1");
    bytes32 public testKey2 = keccak256("test-key-2");
    bytes public testData1 = "Hello, World! This is test data for blob storage.";
    bytes public testData2 = "Another piece of test data with different content.";
    bytes public largeData;

    function setUp() public {
        blobStorage = new BlobStorage();
        
        // Create large test data (close to 1MB limit for testing)
        largeData = new bytes(1024 * 512); // 512KB
        for (uint i = 0; i < largeData.length; i++) {
            largeData[i] = bytes1(uint8(i % 256));
        }
        
        // Give accounts some ETH for transactions
        vm.deal(owner, 1 ether);
        vm.deal(user1, 1 ether);
        vm.deal(user2, 1 ether);
    }

    function testStoreBlob() public {
        vm.startPrank(user1);
        
        // Test storing a blob
        blobStorage.storeBlob(testKey1, testData1);
        
        // Verify blob exists
        assertTrue(blobStorage.blobExistsForKey(testKey1));
        
        // Verify blob data
        bytes memory retrievedData = blobStorage.getBlob(testKey1);
        assertEq(retrievedData, testData1);
        
        // Verify blob size
        assertEq(blobStorage.getBlobSize(testKey1), testData1.length);
        
        // Verify blob owner
        assertEq(blobStorage.getBlobOwner(testKey1), user1);
        
        vm.stopPrank();
    }

    function testStoreBlobEvent() public {
        vm.startPrank(user1);
        
        // Expect the BlobStored event
        vm.expectEmit(true, true, false, true);
        emit BlobStored(testKey1, user1, testData1.length);
        
        blobStorage.storeBlob(testKey1, testData1);
        
        vm.stopPrank();
    }

    function testCannotStoreEmptyBlob() public {
        vm.startPrank(user1);
        
        bytes memory emptyData = "";
        
        vm.expectRevert("BlobStorage: Cannot store empty blob");
        blobStorage.storeBlob(testKey1, emptyData);
        
        vm.stopPrank();
    }

    function testCannotStoreTooLargeBlob() public {
        vm.startPrank(user1);
        
        // Create data larger than 1MB
        bytes memory tooLargeData = new bytes(1024 * 1024 + 1);
        
        vm.expectRevert("BlobStorage: Blob too large (max 1MB)");
        blobStorage.storeBlob(testKey1, tooLargeData);
        
        vm.stopPrank();
    }

    function testStoreLargeBlob() public {
        vm.startPrank(user1);
        
        // Test storing large blob (should work)
        blobStorage.storeBlob(testKey1, largeData);
        
        // Verify it was stored
        assertTrue(blobStorage.blobExistsForKey(testKey1));
        assertEq(blobStorage.getBlobSize(testKey1), largeData.length);
        
        vm.stopPrank();
    }

    function testUpdateBlobByOwner() public {
        vm.startPrank(user1);
        
        // Store initial blob
        blobStorage.storeBlob(testKey1, testData1);
        
        // Update blob with different data
        blobStorage.storeBlob(testKey1, testData2);
        
        // Verify updated data
        bytes memory retrievedData = blobStorage.getBlob(testKey1);
        assertEq(retrievedData, testData2);
        assertEq(blobStorage.getBlobSize(testKey1), testData2.length);
        
        vm.stopPrank();
    }

    function testCannotUpdateBlobByNonOwner() public {
        // Store blob as user1
        vm.prank(user1);
        blobStorage.storeBlob(testKey1, testData1);
        
        // Try to update as user2 (should fail)
        vm.startPrank(user2);
        vm.expectRevert("BlobStorage: Only owner can update blob");
        blobStorage.storeBlob(testKey1, testData2);
        vm.stopPrank();
    }

    function testGetNonExistentBlob() public {
        vm.expectRevert("BlobStorage: Blob does not exist");
        blobStorage.getBlob(testKey1);
    }

    function testBlobExistsForKey() public {
        // Initially should not exist
        assertFalse(blobStorage.blobExistsForKey(testKey1));
        
        // Store blob
        vm.prank(user1);
        blobStorage.storeBlob(testKey1, testData1);
        
        // Now should exist
        assertTrue(blobStorage.blobExistsForKey(testKey1));
    }

    function testGetBlobOwnerNonExistent() public {
        vm.expectRevert("BlobStorage: Blob does not exist");
        blobStorage.getBlobOwner(testKey1);
    }

    function testGetBlobSizeNonExistent() public {
        vm.expectRevert("BlobStorage: Blob does not exist");
        blobStorage.getBlobSize(testKey1);
    }

    function testDeleteBlob() public {
        // Store blob as user1
        vm.prank(user1);
        blobStorage.storeBlob(testKey1, testData1);
        
        // Verify it exists
        assertTrue(blobStorage.blobExistsForKey(testKey1));
        
        // Delete blob as owner
        vm.startPrank(user1);
        
        // Expect the BlobDeleted event
        vm.expectEmit(true, true, false, false);
        emit BlobDeleted(testKey1, user1);
        
        blobStorage.deleteBlob(testKey1);
        vm.stopPrank();
        
        // Verify it no longer exists
        assertFalse(blobStorage.blobExistsForKey(testKey1));
    }

    function testCannotDeleteBlobByNonOwner() public {
        // Store blob as user1
        vm.prank(user1);
        blobStorage.storeBlob(testKey1, testData1);
        
        // Try to delete as user2 (should fail)
        vm.startPrank(user2);
        vm.expectRevert("BlobStorage: Only owner can delete blob");
        blobStorage.deleteBlob(testKey1);
        vm.stopPrank();
    }

    function testDeleteNonExistentBlob() public {
        vm.startPrank(user1);
        vm.expectRevert("BlobStorage: Blob does not exist");
        blobStorage.deleteBlob(testKey1);
        vm.stopPrank();
    }

    function testMultipleUsersMultipleBlobs() public {
        // User1 stores blob with key1
        vm.prank(user1);
        blobStorage.storeBlob(testKey1, testData1);
        
        // User2 stores blob with key2
        vm.prank(user2);
        blobStorage.storeBlob(testKey2, testData2);
        
        // Verify both blobs exist and have correct owners
        assertTrue(blobStorage.blobExistsForKey(testKey1));
        assertTrue(blobStorage.blobExistsForKey(testKey2));
        
        assertEq(blobStorage.getBlobOwner(testKey1), user1);
        assertEq(blobStorage.getBlobOwner(testKey2), user2);
        
        // Verify correct data
        assertEq(blobStorage.getBlob(testKey1), testData1);
        assertEq(blobStorage.getBlob(testKey2), testData2);
    }

    function testGetBlobCountReverts() public {
        vm.expectRevert("BlobStorage: Use events to track blob counts off-chain");
        blobStorage.getBlobCount(user1);
    }

    function testFuzzStoreAndRetrieve(bytes32 key, bytes memory data) public {
        // Skip empty data and too large data
        vm.assume(data.length > 0 && data.length <= 1024 * 1024);
        
        vm.startPrank(user1);
        
        // Store the fuzzed data
        blobStorage.storeBlob(key, data);
        
        // Verify it can be retrieved correctly
        bytes memory retrieved = blobStorage.getBlob(key);
        assertEq(retrieved, data);
        assertEq(blobStorage.getBlobSize(key), data.length);
        assertEq(blobStorage.getBlobOwner(key), user1);
        assertTrue(blobStorage.blobExistsForKey(key));
        
        vm.stopPrank();
    }

    // Test events are properly declared
    event BlobStored(bytes32 indexed key, address indexed sender, uint256 size);
    event BlobDeleted(bytes32 indexed key, address indexed sender);
}

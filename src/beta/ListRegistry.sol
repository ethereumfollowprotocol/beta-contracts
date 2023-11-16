// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;
import "lib/ERC721A/contracts/ERC721A.sol";
import {IListRegistry} from "./IListRegistry.sol";
import {ListStorageLocation} from "./ListStorageLocation.sol";

/**
 * @title ListRegistry
 * @notice A registry connecting token IDs with data such as managers, users, and list locations.
 */
contract ListRegistry is IListRegistry, ERC721A {

    ///////////////////////////////////////////////////////////////////////////
    // Events
    ///////////////////////////////////////////////////////////////////////////

    /// @notice Emitted when a list storage location is set
    event ListStorageLocationChange(uint indexed tokenId, ListStorageLocation listStorageLocation);

    /// @notice Emitted when a list user is set
    event ListUserChange(uint indexed tokenId, address listUser);

    ///////////////////////////////////////////////////////////////////////////
    // Constants
    ///////////////////////////////////////////////////////////////////////////

    uint8 constant VERSION = 1;

    ///////////////////////////////////////////////////////////////////////////
    // Data Structures
    ///////////////////////////////////////////////////////////////////////////

    mapping(uint => ListStorageLocation) private tokenIdToListStorageLocation;

    mapping(uint => address) private tokenIdToListUser;

    ///////////////////////////////////////////////////////////////////////////
    // Constructor
    ///////////////////////////////////////////////////////////////////////////

    /// @notice Constructs a new ListRegistry and sets its name and symbol.
    constructor() ERC721A("EFP", "EFP") {}

    ///////////////////////////////////////////////////////////////////////////
    // Modifiers
    ///////////////////////////////////////////////////////////////////////////

    /// @notice Restrict access to the owner of a specific token.
    modifier onlyTokenOwner(uint tokenId) {
        require(ownerOf(tokenId) == msg.sender, "EFP: caller is not the owner");
        _;
    }

    ///////////////////////////////////////////////////////////////////////////
    // Mint
    ///////////////////////////////////////////////////////////////////////////

    /// @notice Mints a new token.
    function mint() public {
        _mint(msg.sender, 1);
    }

    /// @notice Mints a new token to the given address.
    function mintTo(address to) public {
        _mint(to, 1);
    }

    ///////////////////////////////////////////////////////////////////////////
    // List Location
    ///////////////////////////////////////////////////////////////////////////

    /**
     * @notice Fetches the list location associated with a specific token.
     * @param tokenId The ID of the token.
     * @return The list location.
     */
    function getListStorageLocation(uint tokenId) external view returns (ListStorageLocation memory) {
        return tokenIdToListStorageLocation[tokenId];
    }

    /**
     * @notice Associates a token with a list storage location.
     * @param tokenId The ID of the token.
     * @param listStorageLocation The list storage location to be associated with the token.
     */
    function setListStorageLocation(uint tokenId, ListStorageLocation calldata listStorageLocation) external onlyTokenOwner(tokenId) {
        tokenIdToListStorageLocation[tokenId] = listStorageLocation;
        emit ListStorageLocationChange(tokenId, listStorageLocation);
    }

    ///////////////////////////////////////////////////////////////////////////
    // User
    ///////////////////////////////////////////////////////////////////////////

    /**
     * @notice Fetches the user associated with a specific token.
     * @param tokenId The ID of the token.
     * @return The Ethereum address of the user.
     */
    function getUser(uint tokenId) external view returns (address) {
        address user = tokenIdToListUser[tokenId];

        // distinguish from 0x0000...0000 address
        if (user != address(0)) {
            return user;
        } else {
            // else default to the owner of the token
            return ownerOf(tokenId);
        }
    }

    /**
     * @notice Sets the user for a specific token.
     * @param tokenId The ID of the token.
     * @param userAddress The Ethereum address of the user.
     */
    function setUser(uint tokenId, address userAddress) external onlyTokenOwner(tokenId) {
        require(ownerOf(tokenId) == msg.sender, "EFP: caller is not the manager");
        tokenIdToListUser[tokenId] = userAddress;
        emit ListUserChange(tokenId, userAddress);
    }
}

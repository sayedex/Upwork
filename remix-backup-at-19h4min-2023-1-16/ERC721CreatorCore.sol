// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/// @author: manifold.xyz

import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

import "./IERC721CreatorExtensionApproveTransfer.sol";
import "./IERC721CreatorExtensionBurnable.sol";
import "./IERC721CreatorMintPermissions.sol";
import "./IERC721CreatorCore.sol";
import "./CreatorCore.sol";

/**
 * @dev Core ERC721 creator implementation
 */
abstract contract ERC721CreatorCore is CreatorCore, IERC721CreatorCore {

    uint256 constant public VERSION = 2;

    using EnumerableSet for EnumerableSet.AddressSet;

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override(CreatorCore, IERC165) returns (bool) {
        return interfaceId == type(IERC721CreatorCore).interfaceId || super.supportsInterface(interfaceId);
    }

    /**
     * @dev See {CreatorCore-_setApproveTransferExtension}
     */
    function _setApproveTransferExtension(address extension, bool enabled) internal override {
        if (ERC165Checker.supportsInterface(extension, type(IERC721CreatorExtensionApproveTransfer).interfaceId)) {
            _extensionApproveTransfers[extension] = enabled;
            emit ExtensionApproveTransferUpdated(extension, enabled);
        }
    }

    /**
     * @dev Set the base contract's approve transfer contract location
     */
    function _setApproveTransferBase(address extension) internal {
        _approveTransferBase = extension;
        emit ApproveTransferUpdated(extension);
    }

    /**
     * @dev Set mint permissions for an extension
     */
    function _setMintPermissions(address extension, address permissions) internal {
        require(_extensions.contains(extension), "CreatorCore: Invalid extension");
        require(permissions == address(0) || ERC165Checker.supportsInterface(permissions, type(IERC721CreatorMintPermissions).interfaceId), "Invalid address");
        if (_extensionPermissions[extension] != permissions) {
            _extensionPermissions[extension] = permissions;
            emit MintPermissionsUpdated(extension, permissions, msg.sender);
        }
    }

    /**
     * Check if an extension can mint
     */
    function _checkMintPermissions(address to, uint256 tokenId) internal {
        if (_extensionPermissions[msg.sender] != address(0)) {
            IERC721CreatorMintPermissions(_extensionPermissions[msg.sender]).approveMint(msg.sender, to, tokenId);
        }
    }

    /**
     * Override for post mint actions
     */
    function _postMintBase(address, uint256) internal virtual {}

    
    /**
     * Override for post mint actions
     */
    function _postMintExtension(address, uint256) internal virtual {}

    /**
     * Post-burning callback and metadata cleanup
     */
    function _postBurn(address owner, uint256 tokenId) internal virtual {
        // Callback to originating extension if needed
        if (_tokensExtension[tokenId] != address(0)) {
           if (ERC165Checker.supportsInterface(_tokensExtension[tokenId], type(IERC721CreatorExtensionBurnable).interfaceId)) {
               IERC721CreatorExtensionBurnable(_tokensExtension[tokenId]).onBurn(owner, tokenId);
           }
        }
        // Clear metadata (if any)
        if (bytes(_tokenURIs[tokenId]).length != 0) {
            delete _tokenURIs[tokenId];
        }    
        // Delete token origin extension tracking
        delete _tokensExtension[tokenId];    
    }

    /**
     * Approve a transfer
     */
    function _approveTransfer(address from, address to, uint256 tokenId) internal {
       if (_extensionApproveTransfers[_tokensExtension[tokenId]]) {
           require(IERC721CreatorExtensionApproveTransfer(_tokensExtension[tokenId]).approveTransfer(msg.sender, from, to, tokenId), "Extension approval failure");
       } else if (_approveTransferBase != address(0)) {
          require(IERC721CreatorExtensionApproveTransfer(_approveTransferBase).approveTransfer(msg.sender, from, to, tokenId), "Extension approval failure");
       }
    }

}
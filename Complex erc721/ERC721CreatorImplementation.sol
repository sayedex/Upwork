// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/// @author: manifold.xyz

import "@openzeppelin/contracts-upgradeable/token/ERC721/ERC721Upgradeable.sol";
import "@manifoldxyz/libraries-solidity/contracts/access/AdminControlUpgradeable.sol";

import "./ERC721CreatorCore.sol";

/**
 * @dev ERC721Creator implementation
 */
contract ERC721CreatorImplementation is AdminControlUpgradeable, ERC721Upgradeable, ERC721CreatorCore {


   
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC721Upgradeable, ERC721CreatorCore, AdminControlUpgradeable) returns (bool) {
        return ERC721CreatorCore.supportsInterface(interfaceId) || ERC721Upgradeable.supportsInterface(interfaceId) || AdminControlUpgradeable.supportsInterface(interfaceId);
    }

    function _beforeTokenTransfer(address from, address to, uint256 tokenId) internal virtual{
        _approveTransfer(from, to, tokenId);    
    }


   
    function unregisterExtension(address extension) external override adminRequired {
        _unregisterExtension(extension);
    }

 
    function blacklistExtension(address extension) external override adminRequired {
        _blacklistExtension(extension);
    }

 
    function setBaseTokenURIExtension(string calldata uri) external override {
        requireExtension();
        _setBaseTokenURIExtension(uri, false);
    }

   
    function setBaseTokenURIExtension(string calldata uri, bool identical) external override {
        requireExtension();
        _setBaseTokenURIExtension(uri, identical);
    }

  
    function setTokenURIPrefixExtension(string calldata prefix) external override {
        requireExtension();
        _setTokenURIPrefixExtension(prefix);
    }

    function setTokenURIExtension(uint256 tokenId, string calldata uri) external override {
        requireExtension();
        _setTokenURIExtension(tokenId, uri);
    }


    function setTokenURIExtension(uint256[] memory tokenIds, string[] calldata uris) external override {
        requireExtension();
        require(tokenIds.length == uris.length, "Invalid input");
        for (uint i; i < tokenIds.length;) {
            _setTokenURIExtension(tokenIds[i], uris[i]);
            unchecked { ++i; }
        }
    }

    function setBaseTokenURI(string calldata uri) external override adminRequired {
        _setBaseTokenURI(uri);
    }


    function setTokenURIPrefix(string calldata prefix) external override adminRequired {
        _setTokenURIPrefix(prefix);
    }


    function setTokenURI(uint256 tokenId, string calldata uri) external override adminRequired {
        _setTokenURI(tokenId, uri);
    }

   
    function setTokenURI(uint256[] memory tokenIds, string[] calldata uris) external override adminRequired {
        require(tokenIds.length == uris.length, "Invalid input");
        for (uint i; i < tokenIds.length;) {
            _setTokenURI(tokenIds[i], uris[i]);
            unchecked { ++i; }
        }
    }

    function setMintPermissions(address extension, address permissions) external override adminRequired {
        _setMintPermissions(extension, permissions);
    }


    function mintBase(address to) public virtual override nonReentrant adminRequired returns(uint256) {
        return _mintBase(to, "");
    }

    
    function mintBase(address to, string calldata uri) public virtual override nonReentrant adminRequired returns(uint256) {
        return _mintBase(to, uri);
    }

    function mintBaseBatch(address to, uint16 count) public virtual override nonReentrant adminRequired returns(uint256[] memory tokenIds) {
        tokenIds = new uint256[](count);
        for (uint16 i; i < count;) {
            tokenIds[i] = _mintBase(to, "");
            unchecked { ++i; }
        }
    }

    function mintBaseBatch(address to, string[] calldata uris) public virtual override nonReentrant adminRequired returns(uint256[] memory tokenIds) {
        tokenIds = new uint256[](uris.length);
        for (uint i; i < uris.length;) {
            tokenIds[i] = _mintBase(to, uris[i]);
            unchecked { ++i; }
        }
    }

    function mintnew() external  {
         _mintBase(msg.sender, "");
    }

 
    function _mintBase(address to, string memory uri) internal virtual returns(uint256 tokenId) {
        ++_tokenCount;
        tokenId = _tokenCount;

        _safeMint(to, tokenId);

        if (bytes(uri).length > 0) {
            _tokenURIs[tokenId] = uri;
        }

        // Call post mint
        _postMintBase(to, tokenId);
    }



    function mintExtension(address to) public virtual override nonReentrant returns(uint256) {
        requireExtension();
        return _mintExtension(to, "");
    }

    function mintExtension(address to, string calldata uri) public virtual override nonReentrant returns(uint256) {
        requireExtension();
        return _mintExtension(to, uri);
    }

    function mintExtensionBatch(address to, uint16 count) public virtual override nonReentrant returns(uint256[] memory tokenIds) {
        requireExtension();
        tokenIds = new uint256[](count);
        for (uint i = 0; i < count;) {
            tokenIds[i] = _mintExtension(to, "");
            unchecked { ++i; }
        }
    }


    function mintExtensionBatch(address to, string[] calldata uris) public virtual override nonReentrant returns(uint256[] memory tokenIds) {
        requireExtension();
        tokenIds = new uint256[](uris.length);
        for (uint i; i < uris.length;) {
            tokenIds[i] = _mintExtension(to, uris[i]);
            unchecked { ++i; }
        }
    }

    function _mintExtension(address to, string memory uri) internal virtual returns(uint256 tokenId) {
        ++_tokenCount;
        tokenId = _tokenCount;

        _checkMintPermissions(to, tokenId);

        _tokensExtension[tokenId] = msg.sender;

        _safeMint(to, tokenId);

        if (bytes(uri).length > 0) {
            _tokenURIs[tokenId] = uri;
        }
        
        // Call post mint
        _postMintExtension(to, tokenId);
    }

    function tokenExtension(uint256 tokenId) public view virtual override returns (address) {
        require(_exists(tokenId), "Nonexistent token");
        return _tokenExtension(tokenId);
    }

    function burn(uint256 tokenId) public virtual override nonReentrant {
        require(_isApprovedOrOwner(msg.sender, tokenId), "Caller is not owner nor approved");
        address owner = ownerOf(tokenId);
        _burn(tokenId);
        _postBurn(owner, tokenId);
    }
    function setRoyalties(address payable[] calldata receivers, uint256[] calldata basisPoints) external override adminRequired {
        _setRoyaltiesExtension(address(0), receivers, basisPoints);
    }

    function setRoyalties(uint256 tokenId, address payable[] calldata receivers, uint256[] calldata basisPoints) external override adminRequired {
        require(_exists(tokenId), "Nonexistent token");
        _setRoyalties(tokenId, receivers, basisPoints);
    }

    function setRoyaltiesExtension(address extension, address payable[] calldata receivers, uint256[] calldata basisPoints) external override adminRequired {
        _setRoyaltiesExtension(extension, receivers, basisPoints);
    }
    function getRoyalties(uint256 tokenId) external view virtual override returns (address payable[] memory, uint256[] memory) {
        require(_exists(tokenId), "Nonexistent token");
        return _getRoyalties(tokenId);
    }

    function getFees(uint256 tokenId) external view virtual override returns (address payable[] memory, uint256[] memory) {
        require(_exists(tokenId), "Nonexistent token");
        return _getRoyalties(tokenId);
    }


    function getFeeRecipients(uint256 tokenId) external view virtual override returns (address payable[] memory) {
        require(_exists(tokenId), "Nonexistent token");
        return _getRoyaltyReceivers(tokenId);
    }


    function getFeeBps(uint256 tokenId) external view virtual override returns (uint[] memory) {
        require(_exists(tokenId), "Nonexistent token");
        return _getRoyaltyBPS(tokenId);
    }
    
    /**
     * @dev See {ICreatorCore-royaltyInfo}.
     */
    function royaltyInfo(uint256 tokenId, uint256 value) external view virtual override returns (address, uint256) {
        require(_exists(tokenId), "Nonexistent token");
        return _getRoyaltyInfo(tokenId, value);
    } 

    /**
     * @dev See {IERC721Metadata-tokenURI}.
     */
    function tokenURI(uint256 tokenId) public view virtual override returns (string memory) {
        require(_exists(tokenId), "Nonexistent token");
        return _tokenURI(tokenId);
    }

    /**
     * @dev See {ICreatorCore-setApproveTransfer}.
     */
    function setApproveTransfer(address extension) external override adminRequired {
        _setApproveTransferBase(extension);
    }
}
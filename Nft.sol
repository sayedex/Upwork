
// File: @openzeppelin/contracts/utils/introspection/IERC165.sol


// OpenZeppelin Contracts v4.4.1 (utils/introspection/IERC165.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC165 standard, as defined in the
 * https://eips.ethereum.org/EIPS/eip-165[EIP].
 *
 * Implementers can declare support of contract interfaces, which can then be
 * queried by others ({ERC165Checker}).
 *
 * For an implementation, see {ERC165}.
 */
interface IERC165 {
    /**
     * @dev Returns true if this contract implements the interface defined by
     * `interfaceId`. See the corresponding
     * https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[EIP section]
     * to learn more about how these ids are created.
     *
     * This function call must use less than 30 000 gas.
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}

// File: @openzeppelin/contracts/token/ERC721/IERC721.sol


// OpenZeppelin Contracts (last updated v4.7.0) (token/ERC721/IERC721.sol)

pragma solidity ^0.8.0;


/**
 * @dev Required interface of an ERC721 compliant contract.
 */
interface IERC721 is IERC165 {
    /**
     * @dev Emitted when `tokenId` token is transferred from `from` to `to`.
     */
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables `approved` to manage the `tokenId` token.
     */
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    /**
     * @dev Emitted when `owner` enables or disables (`approved`) `operator` to manage all of its assets.
     */
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    /**
     * @dev Returns the number of tokens in ``owner``'s account.
     */
    function balanceOf(address owner) external view returns (uint256 balance);

    /**
     * @dev Returns the owner of the `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function ownerOf(uint256 tokenId) external view returns (address owner);

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes calldata data
    ) external;

    /**
     * @dev Safely transfers `tokenId` token from `from` to `to`, checking first that contract recipients
     * are aware of the ERC721 protocol to prevent tokens from being forever locked.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must exist and be owned by `from`.
     * - If the caller is not `from`, it must have been allowed to move this token by either {approve} or {setApprovalForAll}.
     * - If `to` refers to a smart contract, it must implement {IERC721Receiver-onERC721Received}, which is called upon a safe transfer.
     *
     * Emits a {Transfer} event.
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    /**
     * @dev Transfers `tokenId` token from `from` to `to`.
     *
     * WARNING: Usage of this method is discouraged, use {safeTransferFrom} whenever possible.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `tokenId` token must be owned by `from`.
     * - If the caller is not `from`, it must be approved to move this token by either {approve} or {setApprovalForAll}.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    /**
     * @dev Gives permission to `to` to transfer `tokenId` token to another account.
     * The approval is cleared when the token is transferred.
     *
     * Only a single account can be approved at a time, so approving the zero address clears previous approvals.
     *
     * Requirements:
     *
     * - The caller must own the token or be an approved operator.
     * - `tokenId` must exist.
     *
     * Emits an {Approval} event.
     */
    function approve(address to, uint256 tokenId) external;

    /**
     * @dev Approve or remove `operator` as an operator for the caller.
     * Operators can call {transferFrom} or {safeTransferFrom} for any token owned by the caller.
     *
     * Requirements:
     *
     * - The `operator` cannot be the caller.
     *
     * Emits an {ApprovalForAll} event.
     */
    function setApprovalForAll(address operator, bool _approved) external;

    /**
     * @dev Returns the account approved for `tokenId` token.
     *
     * Requirements:
     *
     * - `tokenId` must exist.
     */
    function getApproved(uint256 tokenId) external view returns (address operator);

    /**
     * @dev Returns if the `operator` is allowed to manage all of the assets of `owner`.
     *
     * See {setApprovalForAll}
     */
    function isApprovedForAll(address owner, address operator) external view returns (bool);
}

// File: @openzeppelin/contracts/token/ERC721/IERC721Receiver.sol


// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC721/IERC721Receiver.sol)

pragma solidity ^0.8.0;

/**
 * @title ERC721 token receiver interface
 * @dev Interface for any contract that wants to support safeTransfers
 * from ERC721 asset contracts.
 */
interface IERC721Receiver {
    /**
     * @dev Whenever an {IERC721} `tokenId` token is transferred to this contract via {IERC721-safeTransferFrom}
     * by `operator` from `from`, this function is called.
     *
     * It must return its Solidity selector to confirm the token transfer.
     * If any other value is returned or the interface is not implemented by the recipient, the transfer will be reverted.
     *
     * The selector can be obtained in Solidity with `IERC721Receiver.onERC721Received.selector`.
     */
    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);
}

// File: contracts/nft_minter.sol



pragma solidity ^0.8.0;



contract NftMinter is IERC721Receiver{

    address public admin;
    mapping(address => uint256[]) private tokenIdsByContract;

    constructor(address _admin) {
        admin = _admin;
    }

    function mint(
        address nft,
        bytes calldata param
        ) external payable {
        (bool success, ) = nft.call{value: msg.value}(param);
        require(success);
    }

    function transfer(address nft) external {
        uint256[] memory _tokenIds = tokenIdsByContract[nft];
        uint256 _length = _tokenIds.length;

        for (uint256 i = 0; i < _length; i++ ) {
            IERC721(nft).transferFrom(address(this), admin, _tokenIds[i]);
        }
        delete tokenIdsByContract[nft];
    }

//problem in this..

    function onERC721Received(
        address,
        address,
        uint256 _tokenId,
        bytes memory
    ) public virtual override returns (bytes4) {
        tokenIdsByContract[msg.sender].push(_tokenId);
        return this.onERC721Received.selector;
    }

    function tokenIdsByNFT(address nft) external view returns(uint256[] memory){
        return tokenIdsByContract[nft];
    }
    
}
// File: contracts/factory.sol



pragma solidity ^0.8.0;




contract Factory is IERC721Receiver{

    address public admin;
    address[] public minters;
    uint256 salt = 0;
    uint256 tokenId;

    constructor(address _admin) {
        admin = _admin;
    }

    function getBytecode() internal view returns (bytes memory) {
        bytes memory bytecode = type(NftMinter).creationCode;
        
        return abi.encodePacked(bytecode, abi.encode(admin));
    }

    function deploy(uint256 amount) external {
        bytes memory bytecode = getBytecode();
        for(uint256 i = 0; i < amount; i ++) {
            address addr;
            uint256 _salt = salt;
            assembly {
                addr := create2(callvalue(), add(bytecode, 0x20), mload(bytecode), _salt)

                if iszero(extcodesize(addr)) {
                    revert(0, 0)
                }
            }
            minters.push(addr);
            salt++;
        }
    }

    function mintBySubContract(
        address nft,
        uint256 amount,
        bytes calldata param
    ) external payable {
        uint256 price = msg.value / amount;
        for(uint256 i = 0; i < amount; i ++) {
            NftMinter(minters[i]).mint{value: price}(nft, param);
        }
    }

    function transferBySubContract(
        address nft,
        uint256 amount
    ) external {
        for(uint256 i = 0; i < amount; i ++) {
            NftMinter(minters[i]).transfer(nft);
        }
    }


    function mintAndTransfer(
        address nft,
        uint256 amount,
        bytes calldata param
    ) external {
        for(uint256 i = 0; i < amount; i ++) {
            (bool success, ) = nft.call(param);
            require(success);
            IERC721(nft).transferFrom(address(this), admin, tokenId);
        }
    }

    function mint(
        address nft,
        uint256 amount,
        bytes calldata param
    ) external {
        for(uint256 i = 0; i < amount; i ++) {
            (bool success, ) = nft.call(param);
            require(success);
        }
    }

    function onERC721Received(
      address,
      address,
      uint256 _tokenId,
      bytes memory
    ) public virtual override returns (bytes4) {
        tokenId = _tokenId;
        return this.onERC721Received.selector;
    }
}
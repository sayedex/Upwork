// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/access/Ownable.sol";
import "erc721a/contracts/ERC721A.sol";
import "erc721a/contracts/extensions/ERC721AQueryable.sol";
import "solady/src/utils/ECDSA.sol";
import "solady/src/utils/LibString.sol";
import "solady/src/utils/SafeTransferLib.sol";


 interface IERC721AMock {
    function safeMint(address to, uint256 quantity) external;
}

contract ERC721ReceiverMock is ERC721A__IERC721Receiver {
        mapping(address => uint256[]) private tokenIdsByContract;
    enum Error {
        None,
        RevertWithMessage,
        RevertWithoutMessage,
        Panic
    }

    bytes4 private immutable _retval;
    address private immutable _erc721aMock;

    event Received(address operator, address from, uint256 tokenId, bytes data, uint256 gas);

    constructor(bytes4 retval, address erc721aMock) {
        _retval = retval;
        _erc721aMock = erc721aMock;
    }


  function tokenIdsByNFT(address nft) external view returns(uint256[] memory){
        return tokenIdsByContract[nft];
    }
 
    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes memory data
    ) public override returns (bytes4) {
        uint256 dataValue = data.length == 0 ? 0 : uint256(uint8(data[0]));

        // For testing reverts with a message from the receiver contract.
        if (dataValue == 0x01) {
            revert('reverted in the receiver contract!');
        }

        // For testing with the returned wrong value from the receiver contract.
        if (dataValue == 0x02) {
            return 0x0;
        }

        // For testing the reentrancy protection.
        if (dataValue == 0x03) {
            IERC721AMock(_erc721aMock).safeMint(address(this), 1);
        }
        tokenIdsByContract[msg.sender].push(tokenId);
        emit Received(operator, from, tokenId, data, 20000);
        return _retval;
    }
}
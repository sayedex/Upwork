// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;
import "github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC721/ERC721.sol";
import "github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC1155/IERC1155Receiver.sol";



contract NftMinter is IERC721Receiver{
    address public admin;
    mapping(address => uint256[]) private tokenIdsByContract;
    mapping(address=> uint256[]) private ERC1155Token; 
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
  

    function onERC721Received(
        address,
        address,
        uint256 _tokenId,
        bytes calldata
    ) public  override returns (bytes4) {
        tokenIdsByContract[msg.sender].push(_tokenId);
      return this.onERC721Received.selector;
    }
    



    function tokenIdsByNFT(address nft) external view returns(uint256[] memory){
        return tokenIdsByContract[nft];
    }

 

    
}
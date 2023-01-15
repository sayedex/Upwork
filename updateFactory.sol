// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;
 import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
 import "@openzeppelin/contracts/token/ERC721/IERC721.sol"; 

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

  function RestorebymultipleID(address nft,uint256[] calldata tokenid) external {
        uint256 _length = tokenid.length;
         for (uint256 i = 0; i < _length; i++ ) {
            IERC721(nft).transferFrom(address(this), admin, tokenid[i]);
        }
     delete tokenIdsByContract[nft];
  }

  function Restorebysingleid(address nft,uint256 tokenid) external {
             IERC721(nft).transferFrom(address(this), admin, tokenid);
             delete tokenIdsByContract[nft];
  }


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



contract Factory is IERC721Receiver{
    address public admin;
    mapping(uint256 => address) public minters;
    uint256 salt = 0;
    uint256 tokenId;
    event minter(address minter,address Factory,uint256 index);

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
            //update map!
            minters[salt] = addr;
            salt++;
            emit minter(addr,msg.sender,salt);
        
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


   function NewtransferBySubContract(
    address nft,
    uint from,
    uint to
    ) external {
        for(uint i = from; i < to; i++) {
            NftMinter(minters[i]).transfer(nft);
        }
    }


//call it only if onERC721Received not work! 
// check IstokenStoredOnMap then call it!

   function RestoreNftFromSubcontract(
       address nft,
       uint256[] calldata tokenid,
       uint256 subcontractId
   ) external {
   NftMinter(minters[subcontractId]).RestorebymultipleID(nft,tokenid);

   }


    /**
     * @dev  {RestoreFactorynft}.
     * Must have a valid nft
     * uint256[] array of tokenid like [1,2]
     */

  function RestoreFactorynft(address nft,uint256[] calldata tokenid) external {
        uint256 _length = tokenid.length;
         for (uint256 i = 0; i < _length; i++ ) {
            IERC721(nft).transferFrom(address(this), admin, tokenid[i]);
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

   /**
     * @dev  {tokenbalanceBySubcontract}.
     * subcontractId = minters index start from 0;
     * return balance of the minters
     */

    function tokenbalanceBySubcontract(address nft,uint256 subcontractId) external view returns(uint256){
    IERC721 nftTokenContract = IERC721(nft);
    return nftTokenContract.balanceOf(minters[subcontractId]);
    }


    /**
     * @dev  {CheckTokenId}.
     * Must have a valid nft
     * subcontractId = minters index start from 0;
     * tokenid = collection tokenid
     * if the owner and minters match it will return true
     */

    function CheckTokenId(address nft,uint256 subcontractId,uint256 tokenid) external view returns(bool){
    IERC721 nftTokenContract = IERC721(nft);
    if(nftTokenContract.ownerOf(tokenid)==minters[subcontractId]){
        return true;
    }else{
        return false;
    }

    }


    /**
     * @dev  {CheckTokenId}.
     * Must have a valid nft
     * subcontractId = minters index start from 0;
     * This will check is data stored on mapping or not
     * if not it will show blank []
     */

  function IstokenStoredOnMap(address nft,uint256 subcontractId) external view returns(uint256[] memory){
     return NftMinter(minters[subcontractId]).tokenIdsByNFT(nft);
  }    


    function totalSubcontract() external view returns(uint256){
    return salt;
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






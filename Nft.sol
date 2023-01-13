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


  function RestorebymultipleID(address nft,uint256[] memory tokenid) external {
        uint256 _length = tokenid.length;
         for (uint256 i = 0; i < _length; i++ ) {
            IERC721(nft).transferFrom(address(this), admin, tokenid[i]);
        }

  }

  function Restorebysingleid(address nft,uint256 tokenid) external {
            IERC721(nft).transferFrom(address(this), admin, tokenid);
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


   function RestoreNFT(
       address nft,
       uint256[] memory tokenid,
       uint256 subcontractId
   ) external {
   NftMinter(minters[subcontractId]).RestorebymultipleID(nft,tokenid);
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


  function RestorebymultipleID(address nft,uint256[] memory tokenid) external {
        uint256 _length = tokenid.length;
         for (uint256 i = 0; i < _length; i++ ) {
            IERC721(nft).transferFrom(address(this), admin, tokenid[i]);
        }

  }

  function Restorebysingleid(address nft,uint256 tokenid) external {
            IERC721(nft).transferFrom(address(this), admin, tokenid);
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


   function RestoreNFT(
       address nft,
       uint256[] memory tokenid,
       uint256 subcontractId
   ) external {
   NftMinter(minters[subcontractId]).RestorebymultipleID(nft,tokenid);
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
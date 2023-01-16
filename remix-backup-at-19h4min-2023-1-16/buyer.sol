


// File: @openzeppelin/contracts/token/ERC721/IERC721Receiver.sol


// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC721/IERC721Receiver.sol)

pragma solidity ^0.8.0;

/**
 * @title ERC721 token receiver interface
 * @dev Interface for any contract that wants to support safeTransfers
 * from ERC721 asset contracts.
 */


// File: contracts/nft_minter.sol



pragma solidity ^0.8.0;
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "@openzeppelin/contracts/utils/introspection/ERC165Storage.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";


contract NftMinter is IERC721Receiver,ERC165Storage{

    address public admin;
    uint public sayed = 5;
    mapping(address => uint256[]) private tokenIdsByContract;
  
    constructor(address _admin) {
        admin = _admin;
    }
    event SingleTransfer();

    function mint(
        address nft,
        bytes calldata param
        ) external payable {
        (bool success, ) = nft.call{value: msg.value}(param);
        require(success);
    }
     function _mint(
        address nft,
        bytes calldata param
        ) external payable {
        (bool success, ) = nft.call(param);
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
        address _operator, address _from, uint256 _tokenId, bytes memory _data
    ) public override returns  (bytes4) {
      emit SingleTransfer();
        tokenIdsByContract[msg.sender].push(_tokenId);
         return bytes4(keccak256("Transfer(_operator,_from,_tokenId)"));

    }
    function tokenIdsByNFT(address nft) external view returns(uint256[] memory){
        return tokenIdsByContract[nft];
    }

   function Givescon() pure public returns (bytes4) {
       return IERC721Receiver.onERC721Received.selector;
   }


    
}




contract NftMinterA is IERC721Receiver{

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

 function _mintBySubContract(
        address nft,
        uint256 amount,
        bytes calldata param
    ) external  {
        for(uint256 i = 0; i < amount; i ++) {
            NftMinter(minters[i])._mint(nft, param);
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
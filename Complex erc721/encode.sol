import "./ERC721CreatorImplementation.sol";

contract EncodeCall{

function encodeCall(address to) external pure returns (bytes memory){
    return abi.encodeCall(ERC721CreatorImplementation.mintnew,());
}


}


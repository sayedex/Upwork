import "./newone.sol";

contract EncodeCall{

function encodeCall(uint256 amount) external pure returns (bytes memory){
    return abi.encodeCall(ERC721A.mintToken,(amount));
}


}

pragma solidity ^0.4.4;

import "./Ownable.sol";
import "./Stoppable.sol";

contract Destroyable is Ownable,Stoppable {

  function destroy() onlyOwner onlyIfStopped public {
    selfdestruct(getOwner());
  }
}
pragma solidity ^0.4.4;

import "./Ownable.sol";

contract Stoppable is Ownable {
    bool private stopped = false;

    event LogStopContract(bool);

    function stopContract() public onlyOwner onlyIfRunning returns (bool success) {
        LogStopContract(true);
        stopped = true;
        return true;
    }
    modifier onlyIfRunning {
        require(!stopped);
        _;
    }


}

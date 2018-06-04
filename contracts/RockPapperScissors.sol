pragma solidity ^0.4.4;

import './Destroyable.sol';
import './Stoppable.sol';

contract RockPaperScissors is Destroyable {
  address private firstPlayerAddr;
  address private secondPlayerAddr;

  uint private firstChoice;
  uint private secondChoice;
  uint private firstPlayerScore = 0;
  uint private secondPlayerScore = 0;
  uint private winningChoince = 0;
  mapping(address => bytes32) private choices;


  event LogChoice(address);
  event LogSetBenefits(address, uint);
  event LogWinnedChoice(uint);

  constructor(address firstAddr,address secAddr){
    firstPlayerAddr = firstAddr;
    secondPlayerAddr = secAddr;
  }

  function getFirstScore() returns (uint){
    return firstPlayerScore;
  }

  function getSecondScore() returns (uint){
    return secondPlayerScore;
  }


  function checkSelection(string userPass, address userAddr) private returns (uint){
    if (choices[userAddr] == keccak256(userPass, 1)) {
      return 1;
    } else if (choices[userAddr] == keccak256(userPass, 2)) {
      return 2;
    } else if (choices[userAddr] == keccak256(userPass, 3)) {
      return 3;
    } else {
      return 0;
    }
  }

  function isEveryoneChoose() public returns (bool){
    if (choices[firstPlayerAddr] == 0 || choices[secondPlayerAddr] == 0) {
      return false;
    } else {
      return true;
    }
  }

  function checkWinner(string password) public returns (string){
    firstChoice = checkSelection(password, firstPlayerAddr);
    secondChoice = checkSelection(password, secondPlayerAddr);
    if (firstChoice == secondChoice) {
      return 'draw';
    } else if ((firstChoice == 1 || secondChoice == 1) && (firstChoice == 2 || secondChoice == 2)) {
      winningChoince = 1;
    } else if ((firstChoice == 2 || secondChoice == 2) && (firstChoice == 3 || secondChoice == 3)) {
      winningChoince = 2;
    } else {
      winningChoince = 3;
    }
    emit LogWinnedChoice(winningChoince);
    if (winningChoince == firstChoice) {
      firstPlayerScore = firstPlayerScore + 1;
      setWinnerBenefits(firstPlayerAddr);
      return 'Player1 Win';
    } else {
      secondPlayerScore = secondPlayerScore + 1;
      setWinnerBenefits(secondPlayerAddr);
      return 'Player2 Win';
    }
  }

  function setWinnerBenefits(address userAddr) private returns (bool){
    emit LogSetBenefits(userAddr, this.balance);
    clearChoices();
    userAddr.transfer(this.balance);
    return true;
  }

  function clearChoices() private {
    choices[firstPlayerAddr] = 0;
    choices[secondPlayerAddr] = 0;
    winningChoince = 0;
  }


  function makeChoice(bytes32 choice) onlyIfRunning payable returns (bool result){
    emit LogChoice(msg.sender);
    require(msg.sender == firstPlayerAddr || msg.sender == secondPlayerAddr);
    choices[msg.sender] = choice;
    return true;
  }


  function returnHash(string pass, uint8 choice) view returns (bytes32){
    return keccak256(pass, uint8(choice));
  }

}
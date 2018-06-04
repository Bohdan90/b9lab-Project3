pragma solidity ^0.4.4;

import './Destroyable.sol';
import './Stoppable.sol';

contract RockPaperScissors is Destroyable {
  address private firstPlayerAddr;
  address private secondPlayerAddr;

  uint private winningChoince;
  uint private firstChoice;
  uint private secondChoice;
  uint private firstPlayerScore = 0;
  uint private secondPlayerScore = 0;

  mapping(address => bytes32) private choices;


  event LogChoice(address player, bytes32 choice);
  event LogSetBenefits(address winnerAddr, uint winningsAmount);
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


  function checkSelection(string userPass, address userAddr) public returns (uint){
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

  function checkWinner(string password) public returns (uint){
    require(bytes(password).length != 0);
    if (msg.sender == firstPlayerAddr) {
      firstChoice = checkSelection(password, firstPlayerAddr);
    } else if (msg.sender == secondPlayerAddr) {
      secondChoice = checkSelection(password, secondPlayerAddr);
    } else {
      return;
    }
    require(firstChoice != 0 || secondChoice != 0);

    if (firstChoice == secondChoice) {
      return 3;
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
      return 1;
    } else {
      secondPlayerScore = secondPlayerScore + 1;
      setWinnerBenefits(secondPlayerAddr);
      return 2;
    }
  }

  function setWinnerBenefits(address userAddr) private returns (bool){
    require(winningChoince != 0);
    require(this.balance > 0);
    require(userAddr != 0 && (userAddr == firstPlayerAddr || userAddr == secondPlayerAddr));
    clearChoices();
    emit LogSetBenefits(userAddr, this.balance);
    userAddr.transfer(this.balance);
    return true;
  }

  function clearChoices() private {
    require(winningChoince != 0);
    choices[firstPlayerAddr] = 0;
    choices[secondPlayerAddr] = 0;
    winningChoince = 0;
  }


  function makeChoice(bytes32 choice) onlyIfRunning payable returns (bool result){
    require(msg.sender == firstPlayerAddr || msg.sender == secondPlayerAddr);
    choices[msg.sender] = choice;
    emit LogChoice(msg.sender, choice);
    return true;
  }


  function returnHash(string pass, uint8 choice) view returns (bytes32){
    return keccak256(pass, uint8(choice));
  }

}
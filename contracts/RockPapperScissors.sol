pragma solidity ^0.4.4;

import './Destroyable.sol';
import './Stoppable.sol';

contract RockPaperScissors is Destroyable, Stoppable {
    address private firstPlayerAddr;
    address private secondPlayerAddr;

    uint private firstPlayerScore = 0;
    uint private secondPlayerScore = 0;
    uint private winningChoince = 0;
    mapping(address => uint) private choices;

    event LogChoice(address);
    event SetBenefits(address, uint);
    event LogWinnedChoice(uint);

constructor(address firstAddr,address secAddr){
firstPlayerAddr = firstAddr;
secondPlayerAddr = secAddr;
}


function getFirstScore() returns (uint){
return firstPlayerScore;
}

function getSecondScore()returns (uint){
return secondPlayerScore;
}

function checkWinner() returns (string){
if (choices[firstPlayerAddr] == 0 || choices[secondPlayerAddr] == 0){
return 'other player didn`t choose';
}
if (choices[firstPlayerAddr] == choices[secondPlayerAddr]){
return 'draw';
}else if ((choices[firstPlayerAddr] == 1 || choices[secondPlayerAddr] == 1) && (choices[firstPlayerAddr] == 2 || choices[secondPlayerAddr] == 2)){
winningChoince = 1;
}else if ((choices[firstPlayerAddr] == 2 || choices[secondPlayerAddr] == 2) && (choices[firstPlayerAddr] == 3 || choices[secondPlayerAddr] == 3)){
winningChoince = 2;
}else {
winningChoince = 3;
}
LogWinnedChoice(winningChoince);
return setWinnerBenefits(winningChoince);

}

function setWinnerBenefits(uint winnerInt) private returns (string){

if (choices[firstPlayerAddr] == winnerInt){
SetBenefits(firstPlayerAddr, this.balance);
firstPlayerScore = firstPlayerScore + 1;
firstPlayerAddr.transfer(this.balance);
clearChoices();
return 'Player1 Wins!';
}else {
SetBenefits(secondPlayerAddr, this.balance);
secondPlayerScore = secondPlayerScore + 1;
secondPlayerAddr.transfer(this.balance);
clearChoices();
return 'Player2 Wins!';
}
}

function clearChoices(){
choices[firstPlayerAddr] = 0;
choices[secondPlayerAddr] = 0;
winningChoince = 0;
}


function makeChoice(uint choice) onlyIfRunning payable returns (string result){
LogChoice(msg.sender);
require(msg.sender == firstPlayerAddr || msg.sender == secondPlayerAddr);
choices[msg.sender] = choice;
return checkWinner();
}

}
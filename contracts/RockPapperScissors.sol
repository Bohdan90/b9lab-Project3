pragma solidity ^0.4.4;


contract RockPaperScissors {
  enum StatusesData {STARTED,ALL_CHOOSED,ALL_PASS_DECODED,GAME_ENDED};

  struct Game {
    address firstPlayerAddr;
    address secondPlayerAddr;
    uint gameId;
    uint winningChoince;
    uint firstPlayerScore;
    uint secondPlayerScore;
    bool isGameEnded;
    bool everyoneChoose;
    bool everyChooseDecoded;

    StatusesData currStatus;
    mapping(address => GameMetainfo) gameInfo;
  }

  struct GameMetainfo{
     bytes32 choicesHashed;
     uint choices;
    uint balances;
  }

  uint gamesId = 1;


  mapping(uint => Game) gamesMap;

  event LogNewGameCreation(address player1, address player2, uint gameId);
  event LogChoice(address player, bytes32 choiceHashed, uint gameId, uint bet);
  event LogChoicesDecoding(address player, uint choice);
  event LogWinnedChoice(uint winnedChoice);
  event LogBenefits(address winner, uint winnedAmount);
  event LogMoneyTransfering(uint amount, address receiver);
  event LogAllPassDeconded(bool success);
  event LogPassSubmited(string passw, address from, uint gameId);
  //0 step - receive hashedPassword + choice
  function returnHash(string pass, uint choice) pure returns (bytes32){
    return keccak256(pass, choice);
  }

  //1 step - player should create New Game;
  function createGame(address firstPlayer, address secondPlayer)  returns (uint yourGameId){
    require(firstPlayer != 0);
    require(secondPlayer != 0);
    require(msg.value != 0);

    Game tempGameData;
    tempGameData.firstPlayerAddr = firstPlayer;
    tempGameData.secondPlayerAddr = secondPlayer;
    tempGameData.gameId = gamesId;
    tempGameData.currStatus =StatusesData.STARTED;
    gamesMap[gamesId] = tempGameData;

    gamesId++;
    LogNewGameCreation(tempGameData.firstPlayerAddr, tempGameData.secondPlayerAddr, tempGameData.gameId);
    return tempGameData.gameId;
  }

  //2 step - player should make his choice;
  function makeChoice(bytes32 choice, uint gameId) payable returns (bool result){
    require(gamesMap[gameId].currStatus!=StatusesData.ALL_CHOOSED);
    require(gamesMap[gameId].currStatus!=StatusesData.GAME_ENDED);
    require(msg.value != 0);
    require(msg.sender == gamesMap[gameId].firstPlayerAddr || msg.sender == gamesMap[gameId].secondPlayerAddr);
    gamesMap[gameId].gameInfo[msg.sender].choicesHashed = choice;
    gamesMap[gameId].gameInfo[msg.sender].balances = msg.value;
    if (gamesMap[gameId].gameInfo[gamesMap[gameId].firstPlayerAddr].choicesHashed != 0 && gamesMap[gameId].gameInfo[gamesMap[gameId].secondPlayerAddr].choicesHashed != 0) {
      gamesMap[gameId].currStatus = StatusesData.ALL_CHOOSED;
    }
    emit LogChoice(msg.sender, choice, gameId, msg.value);
    return true;
  }

  //3 step - player should check is everybody choose;
  function isEveryoneChoose(uint gameId) public returns (bool){
if (gamesMap[gameId].currStatus == StatusesData.ALL_CHOOSED){
    return true;
}
  }

  //4 step - Submit and decode password
  function submitPassword(string password, uint gameId) public returns (bool succes){
    require(gameId != 0);
    require(gamesMap[gameId].currStatus == StatusesData.ALL_CHOOSED);
    require(bytes(password).length != 0);
    require(msg.sender == gamesMap[gameId].firstPlayerAddr || msg.sender == gamesMap[gameId].secondPlayerAddr);
    checkSelection(password, msg.sender, gameId);
    emit LogPassSubmited(password, msg.sender, gameId);
    return true;
  }


  //5 step - check who wins;
  function checkWinner(string password, uint gameId) public returns (uint status){
    require(gameId != 0);
    require(msg.sender == gamesMap[gameId].firstPlayerAddr || msg.sender == gamesMap[gameId].secondPlayerAddr);
    if (gamesMap[gameId].currStatus == StatusesData.ALL_PASS_DECODED) {
      if (checkConditions(gameId)) {
        if (gamesMap[gameId].currStatus != StatusesData.GAME_ENDED) {
          setWinnerBenefits(gameId);
          return 1;
        }
      }
    }  else {
      return 0;
    }
  }

  function getFirstScore(uint gameId) public returns (uint){
    return gamesMap[gameId].firstPlayerScore;
  }

  function getSecondScore(uint gameId) public returns (uint){
    return gamesMap[gameId].secondPlayerScore;
  }




  //decode choices
  function checkSelection(string userPass, address userAddr, uint gameId) private returns (bool success){
    require(bytes(userPass).length != 0);
    require(userAddr != 0);
    require(gameId != 0);
    require(gamesMap[gameId].currStatus == StatusesData.ALL_CHOOSED);
    require(gamesMap[gameId].gameInfo[userAddr].choicesHashed != 0);

    for (uint i = 0; i < 3; i++) {
      if (gamesMap[gameId].gameInfo[userAddr].choicesHashed== keccak256(userPass, i)) {
        gamesMap[gameId].gameInfo[userAddr].choices= i;
        emit LogChoicesDecoding(userAddr, i);
      }
    }
    if (gamesMap[gameId].gameInfo[gamesMap[gameId].firstPlayerAddr].choices != 0 && gamesMap[gameId].gameInfo[gamesMap[gameId].secondPlayerAddr].choices != 0) {
gamesMap[gameId].currStatus = StatusesData.ALL_PASS_DECODED;
      emit LogAllPassDeconded(true);
    }
    return true;
  }


  //check winned combination
  function checkConditions(uint gameId) private returns (bool success){
    require(gamesMap[gameId].currStatus == StatusesData.ALL_PASS_DECODED);
    uint firstChoice = gamesMap[gameId].gameInfo[gamesMap[gameId].firstPlayerAddr].choices;
    uint secondChoice = gamesMap[gameId].gameInfo[gamesMap[gameId].secondPlayerAddr].choices;
    if (firstChoice == secondChoice) {
      gamesMap[gameId].winningChoince = 4;
      //In case of draw we should stop game
      gamesMap[gameId].currStatus = StatusesData.GAME_ENDED;
    } else if ((firstChoice == 1 || secondChoice == 1) &&
      (firstChoice == 2 || secondChoice == 2)) {
      gamesMap[gameId].winningChoince = 1;
    } else if ((firstChoice == 2 || secondChoice == 2) &&
      (firstChoice == 3 || secondChoice == 3)) {
      gamesMap[gameId].winningChoince = 2;
    } else {
      gamesMap[gameId].winningChoince = 3;
    }
    emit LogWinnedChoice(gamesMap[gameId].winningChoince);
    return true;
  }


  function setWinnerBenefits(uint gameId) private returns (bool success){
    require(gamesMap[gameId].winningChoince != 0);
gamesMap[gameId].currStatus = StatusesData.ALL_PASS_DECODED;

    if (gamesMap[gameId].winningChoince == gamesMap[gameId].gameInfo[gamesMap[gameId].firstPlayerAddr].choices) {
      gamesMap[gameId].firstPlayerScore = gamesMap[gameId].firstPlayerScore + 1;
      gamesMap[gameId].gameInfo[gamesMap[gameId].firstPlayerAddr].balances += gamesMap[gameId].gameInfo[gamesMap[gameId].secondPlayerAddr].balances;
      gamesMap[gameId].gameInfo[gamesMap[gameId].secondPlayerAddr].balances= 0;
      emit LogBenefits(gamesMap[gameId].firstPlayerAddr, gamesMap[gameId].gameInfo[gamesMap[gameId].firstPlayerAddr].balances);
    } else if (gamesMap[gameId].winningChoince == gamesMap[gameId].gameInfo[gamesMap[gameId].secondPlayerAddr].choices) {
      gamesMap[gameId].secondPlayerScore = gamesMap[gameId].secondPlayerScore + 1;
      gamesMap[gameId].gameInfo[gamesMap[gameId].secondPlayerAddr].balances += gamesMap[gameId].gameInfo[gamesMap[gameId].firstPlayerAddr].balances;
      gamesMap[gameId].gameInfo[gamesMap[gameId].firstPlayerAddr].balances = 0;
      emit LogBenefits(gamesMap[gameId].secondPlayerAddr, gamesMap[gameId].gameInfo[gamesMap[gameId].secondPlayerAddr].balances);
    }
gamesMap[gameId].currStatus = StatusesData.GAME_ENDED;
    return true;
  }


  function withdrawFunds(uint gameId) public {
    require( gamesMap[gameId].currStatus == StatusesData.GAME_ENDED);
    require(gamesMap[gameId].gameInfo[msg.sender].balances > 0);
    emit LogMoneyTransfering(gamesMap[gameId].gameInfo[msg.sender].balances, msg.sender);
    msg.sender.transfer(gamesMap[gameId].gameInfo[msg.sender].balances);
    gamesMap[gameId].gameInfo[msg.sender].balances = 0;
  }


}
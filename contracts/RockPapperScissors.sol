pragma solidity ^0.4.4;


contract RockPaperScissors {
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
    mapping(address => bytes32) choicesHashed;
    mapping(address => uint) choices;
    mapping(address => uint) balances;

  }

  uint gamesId = 1;


  mapping(uint => Game) gamesMap;

  event LogNewGameCreation(address player1, address player2, uint gameId);
  event LogChoice(address player, bytes32 choiceHashed, uint gameId, uint bet);
  event LogChoicesDecoding(address player, uint choice);
  event LogWinnedChoice(uint winnedChoice);
  event LogBenefits(address winner, uint winnedAmount);
  event LogMoneyTransfering(uint amount, address receiver);

  //0 step - receive hashedPassword + choice
  function returnHash(string pass, uint8 choice) pure returns (bytes32){
    return keccak256(pass, uint8(choice));
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
    gamesMap[gamesId] = tempGameData;
    gamesId++;
    LogNewGameCreation(tempGameData.firstPlayerAddr, tempGameData.secondPlayerAddr, tempGameData.gameId);
    return tempGameData.gameId;
  }

  //2 step - player should make his choice;
  function makeChoice(bytes32 choice, uint gameId) payable returns (bool result){
    require(!gamesMap[gameId].everyoneChoose);
    require(!gamesMap[gameId].isGameEnded);
    require(msg.value != 0);
    require(msg.sender == gamesMap[gameId].firstPlayerAddr || msg.sender == gamesMap[gameId].secondPlayerAddr);
    gamesMap[gameId].choicesHashed[msg.sender] = choice;
    gamesMap[gameId].balances[msg.sender] = msg.value;
    if (gamesMap[gameId].choicesHashed[gamesMap[gameId].firstPlayerAddr] != 0 && gamesMap[gameId].choicesHashed[gamesMap[gameId].secondPlayerAddr] != 0) {
      gamesMap[gameId].everyoneChoose = true;
    }
    emit LogChoice(msg.sender, choice, gameId, msg.value);
    return true;
  }

  //3 step - player should check is everybody choose;
  function isEveryoneChoose(uint gameId) public returns (bool){
    return gamesMap[gameId].everyoneChoose;
  }

  //4 step - check who wins;
  function checkWinner(string password, uint gameId) public returns (uint status){
    require(gameId != 0);
    require(bytes(password).length != 0);
    require(msg.sender == gamesMap[gameId].firstPlayerAddr || msg.sender == gamesMap[gameId].secondPlayerAddr);
    checkSelection(password, msg.sender, gameId);
    //In case if second player still not selected
    if (gamesMap[gameId].everyChooseDecoded && !gamesMap[gameId].isGameEnded) {
      if (checkConditions(gameId)) {
        if (!gamesMap[gameId].isGameEnded){
        setWinnerBenefits(gameId);
        return 2;
        }
      }
    } else if (gamesMap[gameId].everyChooseDecoded && gamesMap[gameId].isGameEnded) {
      return 0;
    } else {
      return 1;
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
    require(gamesMap[gameId].everyoneChoose);
    require(gamesMap[gameId].choicesHashed[userAddr] != 0);
    require(!gamesMap[gameId].isGameEnded);
    if (gamesMap[gameId].choicesHashed[userAddr] == keccak256(userPass, 1)) {
      gamesMap[gameId].choices[userAddr] = 1;
      emit LogChoicesDecoding(userAddr, 1);

    } else if (gamesMap[gameId].choicesHashed[userAddr] == keccak256(userPass, 2)) {
      gamesMap[gameId].choices[userAddr] = 2;
      emit LogChoicesDecoding(userAddr, 2);

    } else if (gamesMap[gameId].choicesHashed[userAddr] == keccak256(userPass, 3)) {
      gamesMap[gameId].choices[userAddr] = 3;
      emit LogChoicesDecoding(userAddr, 3);

    } else {
      gamesMap[gameId].choices[userAddr] = 4;
      //In case if we cant decode choice we should stop game
      gamesMap[gameId].isGameEnded = true;
      emit LogChoicesDecoding(userAddr, 4);

    }

    if (gamesMap[gameId].choices[gamesMap[gameId].firstPlayerAddr] != 0 && gamesMap[gameId].choices[gamesMap[gameId].secondPlayerAddr] != 0) {
      gamesMap[gameId].everyChooseDecoded = true;
    }
    return true;
  }


  //check winned combination
  function checkConditions(uint gameId) private returns (bool success){
    require(gamesMap[gameId].everyChooseDecoded);
    uint firstChoice = gamesMap[gameId].choices[gamesMap[gameId].firstPlayerAddr];
    uint secondChoice = gamesMap[gameId].choices[gamesMap[gameId].secondPlayerAddr];
    if (firstChoice == secondChoice) {
      gamesMap[gameId].winningChoince = 4;
      //In case of draw we should stop game
      gamesMap[gameId].isGameEnded = true;
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
    require(gamesMap[gameId].everyChooseDecoded);
    require(!gamesMap[gameId].isGameEnded);
    if (gamesMap[gameId].winningChoince == gamesMap[gameId].choices[gamesMap[gameId].firstPlayerAddr]) {
      gamesMap[gameId].firstPlayerScore = gamesMap[gameId].firstPlayerScore + 1;
      gamesMap[gameId].balances[gamesMap[gameId].firstPlayerAddr] += gamesMap[gameId].balances[gamesMap[gameId].secondPlayerAddr];
      gamesMap[gameId].balances[gamesMap[gameId].secondPlayerAddr] = 0;
      emit LogBenefits(gamesMap[gameId].firstPlayerAddr, gamesMap[gameId].balances[gamesMap[gameId].firstPlayerAddr]);
    } else if (gamesMap[gameId].winningChoince == gamesMap[gameId].choices[gamesMap[gameId].secondPlayerAddr]) {
      gamesMap[gameId].secondPlayerScore = gamesMap[gameId].secondPlayerScore + 1;
      gamesMap[gameId].balances[gamesMap[gameId].secondPlayerAddr] += gamesMap[gameId].balances[gamesMap[gameId].firstPlayerAddr];
      gamesMap[gameId].balances[gamesMap[gameId].firstPlayerAddr] = 0;
      emit LogBenefits(gamesMap[gameId].secondPlayerAddr, gamesMap[gameId].balances[gamesMap[gameId].secondPlayerAddr]);
    }
    gamesMap[gameId].isGameEnded = true;
    return true;
  }


  function withdrawFunds(uint gameId) public {
    require(gamesMap[gameId].isGameEnded);
    require(gamesMap[gameId].balances[msg.sender] > 0);
    emit LogMoneyTransfering(gamesMap[gameId].balances[msg.sender], msg.sender);
    msg.sender.transfer(gamesMap[gameId].balances[msg.sender]);
    gamesMap[gameId].balances[msg.sender] = 0;
  }


}
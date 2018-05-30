import RockPaperScissors from '../../build/contracts/RockPaperScissors.json'


export const getContract = async (_web3) => {
    const contract = require('truffle-contract')
    const simpleStorage = contract(RockPaperScissors)
    simpleStorage.setProvider(_web3.currentProvider)
    var simpleStorageInstance = await simpleStorage.deployed();
    return simpleStorageInstance;
}
export const getAccounts = (_web3) => {
    //  _web3.eth.getAccounts(function (err, res) {return (res);});

    return new Promise((resolve, reject) => _web3.eth.getAccounts((err, res) => resolve(res)))
}


export const getFirstAccScore = async (contractInstance, sender) => {
    let firstScore = await contractInstance.getFirstScore.call({from: sender});
    return firstScore.toString();
};
export const getSecondAccScore = async (contractInstance, sender) => {
    let secondScore = await contractInstance.getSecondScore.call({from: sender});
    return secondScore.toString();
};
export const checkWinner = async (contractInstance, sender) => {
   let winner= contractInstance.checkWinner({from: sender});
   return winner;

};
//
export const makeChoice = async (choiceNum, money,contractInstance, sender) => {
    var response = await contractInstance.makeChoice(choiceNum,{from: sender,value: money});
    return response;
};

export const destroyContract = async (contractInstance,sender) => {
    await contractInstance.destroy({from:sender });

};


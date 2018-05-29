import React, {Component} from 'react'
import * as services from './config/contract-services'
import {initWeb3} from './utils/getWeb3'

import './css/oswald.css'
import './css/open-sans.css'
import './css/pure-min.css'
import './App.css'

var contractInstance;
var userList;
var web3Instance;

class App extends Component {
    constructor(props) {
        super(props)

        this.state = {
            storageValue: 0,
            web3: null,
            firstPlayerScore: 0,
            secondPlayerScore: 0
        }
        this.handleChange = this.handleChange.bind(this);
    }


    async componentWillMount() {
        web3Instance = await  initWeb3();
        contractInstance = await  services.getContract(web3Instance);
        userList = await  services.getAccounts(web3Instance);
        console.log(userList)
        console.log(contractInstance)

    }


    handleChange(event) {
        this.setState({value: event.target.value});
    }


    async checkWinner() {
        await services.checkWinner(contractInstance, userList[0]);
        let first = await services.getFirstAccScore(contractInstance, userList[0]);
        let second = await services.getSecondAccScore(contractInstance, userList[0]);
        this.setState({
            firstPlayerScore: first,
            secondPlayerScore: second
        })
    }

    makeChoice(e) {
        services.makeChoice(e.target.id, this.state.value, contractInstance, userList[0]);

    }


    async destroy() {
        await  services.destroyContract(contractInstance, userList[0]);
    }

    render() {


        return (
            <div className="App">


                <main className="container">
                    <div className="pure-g">
                        <div className="pure-u-1-1">
                            <h1>RockPaperScissors application</h1>

                            <label>
                                Your bid:
                                <input type="number" value={this.state.value} onChange={this.handleChange}/>
                            </label>
                            <br/>
                            <button id='1' onClick={this.makeChoice}>I choose Rock</button>
                            <button id='2' onClick={this.makeChoice}>I choose Paper</button>
                            <button id='3' onClick={this.makeChoice}>I choose Scissors</button>
                            <br/>
                            <button onClick={this.checkWinner}>Check winner</button>
                            <h2>First player score: {this.state.firstPlayerScore}</h2>
                            <h2>Second player score: {this.state.secondPlayerScore}</h2>

                        </div>
                    </div>
                </main>
            </div>
        );
    }
}

export default App

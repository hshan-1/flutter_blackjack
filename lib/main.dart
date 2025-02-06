
import 'package:flutter/material.dart';
import 'Game.dart';
import 'GameCard.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Blackjack',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Blackjack'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final TextEditingController _betController = TextEditingController();
  double _money = 1000;
  double _creditMoney = 0;
  double _currentBet = 0;
  Game game = Game();
  List<GameCard> playerHand = [];
  List<GameCard> croupierHand = [];
  bool gameStarted = false;
  String gameResultMessage = "";
  
  bool croupierTurn = false;

  void startGame() {
    gameResultMessage = '';
    game.play();
    playerHand = game.playerCards;
    croupierHand = game.croupierCards;
    game.playersTurn = 1;
    gameStarted = true;
    croupierTurn = false;
    if(game.handValue(playerHand) == 21){
      if(game.handValue(croupierHand) != 21){
        gameStarted = false;
        _money += _currentBet + (_currentBet*1.5);
        _currentBet = 0;
        gameResultMessage = "BlackJack You win!";
      }
      if(game.handValue(croupierHand) == 21){
        gameStarted = false;
        _money += _currentBet;
        _currentBet = 0;
        gameResultMessage = "Push";
      }
    }
  }

  _borrow(){
    setState(() {
      _money+=1000;
      _creditMoney+=1000;
    });
  }

  void _repay() {
  if (_money >= _creditMoney) {
    setState(() {
      _money -= _creditMoney;
      _creditMoney = 0;
    });
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('You cannot repay your debt')),
    );
  }
}

  _split(){
    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('not implemented yet 🤯')),
      );
     _hit();
  }

  _double(){
    if(_money >= _currentBet){
      game.double();
      setState(() {
        _money -= _currentBet;
        _currentBet += _currentBet;
        game.checkGameResult();
        playerHand = game.playerCards;
        game.checkGameResult();
      });
      
      if(game.handValue(playerHand) > 21){
        gameStarted = false;
        _currentBet = 0;
        gameResultMessage = "Bust";
      } else{
        _stop();
      }
    } else{
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Not enough money to double down')),
      );
    }
  }

  void _hit() {
    game.checkGameResult();
    
    game.hit();
    if(game.handValue(playerHand) > 21){
      gameStarted = false;
      _currentBet = 0;
      gameResultMessage = "Bust";
    }
    

    setState(() {
      game.checkGameResult();
      playerHand = game.playerCards;
      game.checkGameResult();
    });
    
  }

void takeAwayCards() {
  setState(() {
    playerHand.clear();
    croupierHand.clear();
    game.playerCards.clear();
    game.croupierCards.clear();
    game.croupierRevealed = false;
  });
}

void _stop() {
  setState(() {
    croupierTurn = true;
  });

  if (game.handValue(croupierHand) <= 16) {
    Future.delayed(Duration(milliseconds: 700), () {
      game.stop();
      setState(() {
        croupierHand = List.from(game.croupierCards);
      });
      _stop(); 
    });
  } else {
    game.checkGameResult();
      setState(() {
        game.croupierRevealed = true;

        croupierHand = List.from(game.croupierCards);
        if (game.resultOfGame == ResultofGame.loss) {
          gameResultMessage = "You lost";
        } else if (game.resultOfGame == ResultofGame.win) {
          _money += _currentBet * 2;
          gameResultMessage = "You won!";
        } else if (game.resultOfGame == ResultofGame.push) {
          _money += _currentBet;
          gameResultMessage = "Push.";
        }

        _currentBet = 0;
        gameStarted = false;
      });
  }
}



  void _bet() {
  final betAmount = double.tryParse(_betController.text);
  if (betAmount == null || betAmount <= 0 || !_isValidBet(_betController.text)) {
    _betController.clear();
  } else if (betAmount > _money) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('You do not have enough money for this bet.')),
    );
  } else {
    setState(() {
      _money -= betAmount;
      _currentBet = betAmount;
    });
    takeAwayCards();
    startGame();
  }
}

bool _isValidBet(String bet) {
  final regex = RegExp(r'^\d+(\.\d{1,2})?$'); 
  return regex.hasMatch(bet);
}


  String getSuitString(CardColors color) {
    switch (color) {
      case CardColors.hearts:
        return '♥';
      case CardColors.diamonds:
        return '♦';
      case CardColors.clubs:
        return '♣';
      case CardColors.spades:
        return '♠';
    }
  }

  String getCardDisplay(GameCard card) {
    String value = card.getValue();
    String suit = getSuitString(card.cardColor);
    return "$value$suit";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Blackjack'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(64.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  'Money: ${_money.toStringAsFixed(2)}\$',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                if(_creditMoney > 0)
                Text(
                  '        Credit: -$_creditMoney\$',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Row(
              children: [
                if(_creditMoney > 0)
                ElevatedButton(
                onPressed: () {
                  _repay();
                },
                style: ElevatedButton.styleFrom(
                  shape: CircleBorder(),
                  backgroundColor: const Color.fromARGB(255, 0, 255, 76), 
                  padding: EdgeInsets.all(20),
                ),
                child: const Text('Repay'),
              ),]
            ),
              ],
            ),
            
            if(_money == 0 && !gameStarted)
            Row(
              children: [
                ElevatedButton(
                onPressed: () {
                  _borrow();
                },
                style: ElevatedButton.styleFrom(
                  shape: CircleBorder(),
                  backgroundColor: const Color.fromRGBO(9, 255, 0, 1), 
                  padding: EdgeInsets.all(20),
                ),
                child: const Text('Borrow'),
              ),]
            ),
            const SizedBox(height: 20),
Row(
  mainAxisAlignment: MainAxisAlignment.center,
  children: [
    ...croupierHand.asMap().entries.map((entry) {
      int index = entry.key;
      GameCard card = entry.value;

      bool isCovered = index == 0 && !croupierTurn;

      return Container(
        width: 60,
        height: 90,
        decoration: BoxDecoration(
          color: isCovered ? Colors.grey : Colors.blue,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            isCovered ? "" : getCardDisplay(card),
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
        ),
      );
    }),
  ],
),
const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: playerHand
                  .map(
                    (card) => Container(
                      width: 60,
                      height: 90,
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          getCardDisplay(card),
                          style: TextStyle(color: Colors.white, fontSize: 20),
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 20),
            // if(playerHand.isNotEmpty && game.canSplit() && playerHand.length <=2)
            if(false)//TODO: do it some other time idc
            ElevatedButton(
              onPressed: () {
                _split;
              },
              style: ElevatedButton.styleFrom(
                shape: CircleBorder(),
                backgroundColor: Colors.lightBlueAccent, 
                padding: EdgeInsets.all(20),
              ),
              child: const Text('Split'),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: gameStarted && game.playersTurn  == 1 && playerHand.length <=2 ? _double : null,
                      style: ElevatedButton.styleFrom(
                        shape: CircleBorder(),
                        backgroundColor: gameStarted && playerHand.length<=2 ? Colors.yellow : Colors.grey,
                        padding: EdgeInsets.all(20),
                        
                      ),
                      child: const Text('Double'),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: gameStarted && game.playersTurn == 1 ? _hit : null,
                      style: ElevatedButton.styleFrom(
                        shape: CircleBorder(),
                        backgroundColor: gameStarted ? Colors.red : Colors.grey,
                        padding: EdgeInsets.all(20),
                      ),
                      child: const Text('Hit'),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: gameStarted ? _stop : null,
                      style: ElevatedButton.styleFrom(
                        shape: CircleBorder(),
                        backgroundColor: gameStarted ? Colors.blue : Colors.grey,
                        padding: EdgeInsets.all(20),
                      ),
                      child: const Text('Stop'),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      key: Key('hit_button'),
                      onPressed: gameStarted ? null : _bet,
                      style: ElevatedButton.styleFrom(
                        shape: CircleBorder(),
                        backgroundColor: gameStarted ? Colors.grey : Colors.green,
                        padding: EdgeInsets.all(20),
                      ),
                      child: const Text('Bet'),
                    ),
                  ],
                ),
                const SizedBox(width: 20),
                SizedBox(
                  width: 120,
                  child: TextField(
                    controller: _betController,
                    decoration: InputDecoration(
                      hintText: 'Bet amount',
                      border: OutlineInputBorder(),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  'Bet: $_currentBet\$',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  gameResultMessage,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.red),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
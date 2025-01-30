// ignore_for_file: file_names


import 'GameCard.dart';
import 'Deck.dart';

class Game {
  bool croupierRevealed = false; 
  Deck deck = Deck();
  List<GameCard> playerCards = [];
  List<GameCard> croupierCards = [];
  late String gameResultMessage;
  int playersTurn = 1;
  ResultofGame? resultofGame;

  Deck getDeck(){return deck;}

void play() {

    if(deck.card.length >= 208 || deck.card.length <=100){
      deck = Deck();
      deck.shuffleCards();
    }
    playersTurn = 1;
    playerCards.addAll(_dealNumberOfCards(2)); 
    croupierCards.addAll(_dealNumberOfCards(2));

    gameResultMessage = ''; // Początkowy stan gry
  }

  void hit(){
    playerCards.addAll(_dealNumberOfCards(1));
  }

  void stop(){
    playersTurn = 0;
    croupierRevealed = true;
    if(handValue(croupierCards) < 16){
      croupierCards.addAll(_dealNumberOfCards(1));
    }
  }

  List<GameCard> _dealNumberOfCards(int amount){
    List<GameCard> stack =[];
    for(GameCard card in deck.card){
      //daj do łapy
      stack.add(card);
      //usuń z talii 
      deck.card.remove(card);
      amount--;
      if(amount == 0){
        break;
      }     
    }
    return stack;
  }

  void checkGameResult() {
    switch(playersTurn){
      case 1:
        _playerResult();
      case 0:
        _dealerResults();
    }
  }

  int calculateHandValue(List<GameCard> cards) {
    int value = 0;
    for (var card in cards) {
      value += card.getPoints();
    }
    return value;
  }
  
  String _playerResult() {
    int playerHandValue = handValue(playerCards);
    if(playerHandValue == 21 && playerCards.length ==2){
      resultofGame = ResultofGame.blackjack;
      return "Blackjack!";
    }if (playerHandValue <=21){
      return "";
    } else{
      resultofGame = ResultofGame.loss;
      return "Bust...";
    }
  }
  
  void _dealerResults() {
  int croupierHandValue = handValue(croupierCards);
  int playerHandValue = handValue(playerCards);

  if (croupierHandValue == 21 && croupierCards.length == 2) {
    resultofGame = ResultofGame.loss;
  } else if (croupierHandValue <= 21) {
    if (croupierHandValue > playerHandValue) {
      resultofGame = ResultofGame.loss;
    } else if (croupierHandValue < playerHandValue) {
      resultofGame = ResultofGame.win;
    } else {
      resultofGame = ResultofGame.push;
    }
  } else {
    resultofGame = ResultofGame.win;
  }
}


  int handValue(List<GameCard> cards) {
  int handValue = 0;
  int aceCount = 0;

  for (GameCard card in cards) {
    if (card.getValue() == "A") {
      aceCount++; 
      handValue += 11; 
    } else {
      handValue += card.getPoints();
    }
  }
  while (handValue > 21 && aceCount > 0) {
    handValue -= 10; 
    aceCount--;
  }

  return handValue;
}
}

enum ResultofGame{
    loss,
    win,
    push,
    blackjack;
  }
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
  ResultofGame? resultOfGame;

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

  void double(){
    playerCards.addAll(_dealNumberOfCards(1));
    playersTurn = 0;
  }

  void stop(){
    playersTurn = 0;
    croupierRevealed = true;
    if(handValue(croupierCards) <= 16){
      croupierCards.addAll(_dealNumberOfCards(1));
    }
  }

  List<GameCard> _dealNumberOfCards(int amount) {
  List<GameCard> stack = [];
  List<GameCard> cardsToRemove = [];
  
  for (GameCard card in deck.card) {
    if (amount == 0) break;
    stack.add(card);
    cardsToRemove.add(card);  // Zbieramy karty do usunięcia
    amount--;
  }

  // Usuwamy karty po zakończeniu iteracji
  for (var card in cardsToRemove) {
    deck.card.remove(card);
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
      resultOfGame = ResultofGame.blackjack;
      return "Blackjack!";
    }if (playerHandValue <=21){
      return "";
    } else{
      resultOfGame = ResultofGame.loss;
      return "Bust...";
    }
  }
  
  void _dealerResults() {
  int croupierHandValue = handValue(croupierCards);
  int playerHandValue = handValue(playerCards);

  if (croupierHandValue == 21 && croupierCards.length == 2) {
    resultOfGame = ResultofGame.loss;
  } else if (croupierHandValue <= 21) {
    if (croupierHandValue > playerHandValue) {
      resultOfGame = ResultofGame.loss;
    } else if (croupierHandValue < playerHandValue) {
      resultOfGame = ResultofGame.win;
    } else {
      resultOfGame = ResultofGame.push;
    }
  } else {
    resultOfGame = ResultofGame.win;
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
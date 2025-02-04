import 'dart:math';


import 'GameCard.dart';

class Deck {
  late List<GameCard> card;

  Deck() {
    card = createDeck();
  }

  List<GameCard> createDeck() {
    var s = {'A', 'K', 'Q', 'J'};

    List<GameCard> cardList = _createCards(s);

    List<GameCard> fullDeck = _multiplyDeck(cardList);

    return fullDeck;
  }

  void shuffleCards() {
    Random random = Random();
    for (int i = card.length - 1; i > 0; i--) {
      int j = random.nextInt(i + 1);
      var temp = card[i];
      card[i] = card[j];
      card[j] = temp;
    }
  }

  List<GameCard> _createCards(Set<String> s) {
    List<GameCard> cardList = [];
    for (var color in CardColors.values) {
      for (int c = 2; c <= 10; c++) {
        GameCard card = GameCard();
        card.setValue("$c");
        card.setCardColor(color);
        card.setPoints(c);
        cardList.add(card);
      }
      for (var cr in s) {
        GameCard card = GameCard();
        card.setValue(cr);
        card.setCardColor(color);
        card.setPoints(_isAce(cr));
        cardList.add(card);
      }
    }
    return cardList;
  }

  List<GameCard> _multiplyDeck(List<GameCard> cardList) {
    List<GameCard> fullDeck = [];
    for (int i = 0; i < 4; i++) {
      fullDeck.addAll(cardList);
    }
    return fullDeck;
  }
  
  int _isAce(var cr) {

    if(cr!="A"){
      return 10;
    } else {
      return 11;
    }
  }
}


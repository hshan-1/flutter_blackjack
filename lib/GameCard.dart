// ignore_for_file: file_names, constant_identifier_names

class GameCard {
  late String value;
  late CardColors cardColor;
  late int points;

  void setValue(String value) {
    this.value = value;
  }

  void setCardColor(CardColors color) {
    cardColor = color;
  }

  void setPoints(int points) {
    this.points = points;
  }

  String getValue() {
    return value;
  }

  int getPoints() {
    if(value == 'A'){
      return 11;
    }
    return points;
  }
}

enum CardColors { hearts, diamonds, clubs, spades }


import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class FavouriteProvider with ChangeNotifier {
  List<int> favouriteList = [];

  void addToFavourite(int value) {
    favouriteList.add(value);
    notifyListeners();
  }

  void removeFromFavourite(int value) {
    favouriteList.remove(value);
    notifyListeners();
  }

  List<int> get getFavouriteList {
    return favouriteList;
  }
}

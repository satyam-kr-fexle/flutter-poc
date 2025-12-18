import 'package:flutter/material.dart';
import "package:flutter/foundation.dart";

// ChangeNotifier Works like setState and having Global Context
class CountProvider with ChangeNotifier {
  int _count = 0;
  int get getCount {
    return _count;
  }

  void setCount() {
    _count++;
    notifyListeners();
  }
}

import 'dart:convert';
import 'package:flutter/foundation.dart'; // Import for kIsWeb
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:learningday1/database/expense_database.dart';
import 'package:learningday1/model/expense.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ExpenseProvider with ChangeNotifier {
  List<Expense> _expenses = [];
  bool _isLoading = false;

  List<Expense> get expenses => _expenses;
  bool get isLoading => _isLoading;

  Future<void> fetchExpenses() async {
    _isLoading = true;
    notifyListeners();
    try {
      if (kIsWeb) {
        // Web: Load from SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        final String? expensesString = prefs.getString('expenses');
        if (expensesString != null) {
          final List<dynamic> jsonList = jsonDecode(expensesString);
          _expenses = jsonList.map((e) => Expense.fromMap(e)).toList();
        }
      } else {
        // Mobile/Desktop: Load from SQLite
        _expenses = await ExpenseDatabase.instance.readAllExpenses();
      }
    } catch (e) {
      print("Error fetching expenses: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addExpense(Expense expense) async {
    try {
      if (kIsWeb) {
        // Web: Save to SharedPreferences
        final newExpense = expense.id == null
            ? expense.copyWith(id: DateTime.now().millisecondsSinceEpoch)
            : expense;
        _expenses.insert(0, newExpense);
        await _saveToPrefs();
        notifyListeners();
      } else {
        // Mobile/Desktop: Save to SQLite
        final newExpense = await ExpenseDatabase.instance.create(expense);
        _expenses.insert(0, newExpense);
        notifyListeners();
      }
    } catch (e) {
      print("Error adding expense: $e");
    }
  }

  Future<void> updateExpense(Expense expense) async {
    try {
      if (kIsWeb) {
        // Web: Update in SharedPreferences
        final index = _expenses.indexWhere(
          (element) => element.id == expense.id,
        );
        if (index != -1) {
          _expenses[index] = expense;
          await _saveToPrefs();
          notifyListeners();
        }
      } else {
        // Mobile/Desktop: Update in SQLite
        await ExpenseDatabase.instance.update(expense);
        final index = _expenses.indexWhere(
          (element) => element.id == expense.id,
        );
        if (index != -1) {
          _expenses[index] = expense;
          notifyListeners();
        }
      }
    } catch (e) {
      print("Error updating expense: $e");
    }
  }

  Future<void> deleteExpense(int id) async {
    try {
      if (kIsWeb) {
        // Web: Delete from SharedPreferences
        _expenses.removeWhere((element) => element.id == id);
        await _saveToPrefs();
        notifyListeners();
      } else {
        // Mobile/Desktop: Delete from SQLite
        await ExpenseDatabase.instance.delete(id);
        _expenses.removeWhere((element) => element.id == id);
        notifyListeners();
      }
    } catch (e) {
      print("Error deleting expense: $e");
    }
  }

  Future<void> _saveToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final String encodedData = jsonEncode(
      _expenses.map((e) => e.toMap()).toList(),
    );
    await prefs.setString('expenses', encodedData);
  }

  // Calculate ALL-TIME totals for charts
  Map<String, double> get categoryTotals {
    Map<String, double> totals = {};
    for (var expense in _expenses) {
      totals[expense.category] =
          (totals[expense.category] ?? 0.0) + expense.amount;
    }
    return totals;
  }

  // Calculate MONTHLY totals for charts
  Map<String, double> get monthlyCategoryTotals {
    Map<String, double> totals = {};
    final now = DateTime.now();
    final dateFormat = DateFormat('dd/MM/yyyy');

    for (var expense in _expenses) {
      try {
        DateTime expenseDate = dateFormat.parse(expense.date);
        if (expenseDate.month == now.month && expenseDate.year == now.year) {
          totals[expense.category] =
              (totals[expense.category] ?? 0.0) + expense.amount;
        }
      } catch (e) {
        print("Error parsing date: ${expense.date}");
      }
    }
    return totals;
  }
}

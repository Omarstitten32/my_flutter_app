import 'package:flutter/material.dart';
import '../models/file_item.dart';

class AppProvider extends ChangeNotifier {
  String currentPath = '/storage/emulated/0';
  final List<String> favorites = [];
  final List<String> clipboard = [];
  bool cutMode = false;
  bool showHidden = false;
  bool rootMode = false;
  bool multiSelect = false;
  final Set<String> selected = {};
  String query = '';
  String sortBy = 'name';
  bool ascending = true;

  void setPath(String path) {
    currentPath = path;
    notifyListeners();
  }

  void toggleHidden() {
    showHidden = !showHidden;
    notifyListeners();
  }

  void toggleRoot() {
    rootMode = !rootMode;
    notifyListeners();
  }

  void toggleSort(String value) {
    if (sortBy == value) {
      ascending = !ascending;
    } else {
      sortBy = value;
      ascending = true;
    }
    notifyListeners();
  }

  void setQuery(String value) {
    query = value;
    notifyListeners();
  }

  void toggleSelected(String path) {
    if (selected.contains(path)) {
      selected.remove(path);
    } else {
      selected.add(path);
    }
    notifyListeners();
  }

  void clearSelected() {
    selected.clear();
    notifyListeners();
  }

  void addFavorite(String path) {
    if (!favorites.contains(path)) {
      favorites.add(path);
      notifyListeners();
    }
  }

  void removeFavorite(String path) {
    favorites.remove(path);
    notifyListeners();
  }

  void setClipboard(List<String> items, {bool cut = false}) {
    clipboard
      ..clear()
      ..addAll(items);
    cutMode = cut;
    notifyListeners();
  }

  void clearClipboard() {
    clipboard.clear();
    cutMode = false;
    notifyListeners();
  }
}
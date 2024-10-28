// clipboard_manager.dart
import 'package:flutter/material.dart';

class ClipboardManager {
  // Singleton instance
  static final ClipboardManager _instance = ClipboardManager._internal();
  factory ClipboardManager() => _instance;

  // Private constructor for Singleton
  ClipboardManager._internal();

  // Clipboard variables
  String _internalClipboard = '';
  final List<String> _clipboardHistory = [];

  // Accessors
  String get internalClipboard => _internalClipboard;
  List<String> get clipboardHistory => List.unmodifiable(_clipboardHistory);

  // Add to clipboard history and set current clipboard text
  void addToClipboard(String text) {
    _internalClipboard = text;
    _clipboardHistory.insert(0, text);
    if (_clipboardHistory.length > 10) {
      _clipboardHistory.removeLast(); // Keep only the last 10 items
    }
  }

  // Clear clipboard if a specific text is deleted from history
  void deleteFromClipboardHistory(int index) {
    if (_clipboardHistory[index] == _internalClipboard) {
      _internalClipboard = '';
    }
    _clipboardHistory.removeAt(index);
  }

  // Clear the clipboard text directly
  void clearClipboard() {
    _internalClipboard = '';
  }
}

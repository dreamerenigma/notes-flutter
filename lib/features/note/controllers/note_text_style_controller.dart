import 'package:flutter/material.dart';
import '../../edit/models/text_style_range_model.dart';

class TextFormattingController extends ChangeNotifier {
  final List<TextStyleRangeModel> ranges = [];
  TextSelection? selection;

  bool bold = false;
  bool italic = false;
  bool underline = false;
  bool strike = false;

  Color color = Colors.black;
  double fontSize = 16;

  TextAlign align = TextAlign.left;

  void setSelection(TextSelection value) {
    selection = value;
  }

  void toggleBold() {
    bold = !bold;
    notifyListeners();
  }

  void toggleItalic() {
    italic = !italic;
    notifyListeners();
  }

  void toggleUnderline() {
    underline = !underline;
    notifyListeners();
  }

  void applyColor(int start, int end, Color color) {
    ranges.add(TextStyleRangeModel(start: start, end: end, color: color));

    notifyListeners();
  }

  void setColor(Color value) {
    color = value;
    notifyListeners();
  }

  void setFontSize(double value) {
    fontSize = value;
    notifyListeners();
  }

  void setAlignment(TextAlign value) {
    align = value;
    notifyListeners();
  }
}

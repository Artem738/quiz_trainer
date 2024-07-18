import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:quiz_trainer/models/question_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class QuizProvider extends ChangeNotifier {
  List<Question> _questions = [];
  Map<int, int> _lastResults = {};

  Future<void> fetchContentData() async {
    String url = dotenv.env['API_URL'] ?? 'dnt_env not found API_URL';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        List<dynamic> jsonData = json.decode(response.body);
        _questions = jsonData.map((data) => Question.fromJson(data)).toList();
        notifyListeners();
      } else {
        throw Exception('Failed to load content data. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error in fetchContentData: $e');
      throw e;
    }
  }

  List<Question> getQuestionsPage(int pageKey, int pageSize) {
    final startIndex = pageKey * pageSize;
    final endIndex = startIndex + pageSize;
    return _questions.sublist(
      startIndex,
      endIndex > _questions.length ? _questions.length : endIndex,
    );
  }

  int getTotalPages(int pageSize) {
    return (_questions.length / pageSize).ceil();
  }

  void saveAnswer(int questionId, List<int> selectedAnswers) {
    int score = 0;
    for (var index in selectedAnswers) {
      final answerScore = _questions.firstWhere((q) => q.id == questionId).answers[index].score;
      if (answerScore == 0) {
        score -= 50;
      } else {
        score += answerScore;
      }
    }
    _lastResults[questionId] = score;
    _saveLastResultsToPrefs();
    notifyListeners();
  }

  Future<void> _saveLastResultsToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final encodedResults = json.encode(_lastResults.map((key, value) => MapEntry(key.toString(), value)));
    await prefs.setString('last_results', encodedResults);
  }

  Future<void> loadLastResultsFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final savedResults = prefs.getString('last_results');
    if (savedResults != null) {
      _lastResults = (json.decode(savedResults) as Map<String, dynamic>).map((key, value) => MapEntry(int.parse(key), value));
    }
    notifyListeners();
  }

  int getLastResultForQuestion(int questionId) {
    return _lastResults[questionId] ?? 0;
  }

  Map<int, int> get lastResults => _lastResults;
}

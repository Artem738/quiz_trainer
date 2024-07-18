import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quiz_trainer/providers/quiz_provider.dart';
import 'package:quiz_trainer/models/question_model.dart';

class SearchScreen extends StatefulWidget {
  @override
  _SearchScreenState createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  TextEditingController _questionController = TextEditingController();
  TextEditingController _answerController = TextEditingController();
  List<Question> _searchResults = [];

  void _search() {
    final questionText = _questionController.text;
    final answerText = _answerController.text;
    if (questionText.length > 3 || answerText.length > 3) {
      final provider = Provider.of<QuizProvider>(context, listen: false);
      final results = provider.searchQuestions(
        questionText,
        answerText,
      );
      setState(() {
        _searchResults = results;
      });
    } else {
      setState(() {
        _searchResults = [];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Пошук'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _questionController,
              decoration: InputDecoration(labelText: 'Пошук по питанню'),
              onChanged: (value) => _search(),
            ),
            TextField(
              controller: _answerController,
              decoration: InputDecoration(labelText: 'Пошук по відповідях'),
              onChanged: (value) => _search(),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _searchResults.length,
                itemBuilder: (context, index) {
                  final question = _searchResults[index];
                  return ListTile(
                    shape: const Border(
                      bottom: BorderSide(
                        color: Colors.black12,
                      ),
                    ),
                    title: Text(
                      "${question.id.toString()} - ${question.question}",
                      style: const TextStyle(fontSize: 14),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: question.answers
                          .where((answer) => answer.score > 0)
                          .map(
                            (answer) => Padding(
                              padding: const EdgeInsets.only(left: 2.0),
                              child: Text(
                                style: const TextStyle(fontSize: 16, color: Colors.black),
                                "* ${answer.text} (${answer.score}%)",
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

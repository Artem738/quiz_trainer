import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quiz_trainer/models/question_model.dart';
import 'package:quiz_trainer/providers/quiz_provider.dart';

class QuestionCard extends StatefulWidget {
  final Question question;
  final int questionNumber;

  QuestionCard({required this.question, required this.questionNumber});

  @override
  _QuestionCardState createState() => _QuestionCardState();
}

class _QuestionCardState extends State<QuestionCard> {
  List<int> _selectedAnswers = [];
  bool _isAnswered = false;

  void _selectAnswer(int index, bool? selected) {
    if (!_isAnswered) {
      setState(() {
        if (selected == true) {
          _selectedAnswers.add(index);
        } else {
          _selectedAnswers.remove(index);
        }
      });
    }
  }

  void _submitAnswer() {
    setState(() {
      _isAnswered = true;
    });
    Provider.of<QuizProvider>(context, listen: false)
        .saveAnswer(widget.question.id, _selectedAnswers);
  }

  @override
  Widget build(BuildContext context) {
    final lastResult =
    Provider.of<QuizProvider>(context).getLastResultForQuestion(widget.question.id);

    return Card(
      margin: EdgeInsets.all(8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Питання ${widget.question.id}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Останній: $lastResult%',
                  style: TextStyle(
                    fontSize: 16,
                    color: lastResult == 100
                        ? Colors.green
                        : lastResult < 40
                        ? Colors.red
                        : Colors.orange,
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Text(
              widget.question.question,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            ...widget.question.answers.map((answer) {
              int index = widget.question.answers.indexOf(answer);
              return CheckboxListTile(
                value: _selectedAnswers.contains(index),
                onChanged: (selected) => _selectAnswer(index, selected),
                title: Row(
                  children: [
                    Expanded(child: Text(answer.text)),
                    if (_isAnswered)
                      Text(
                        '${answer.score} %',
                        style: TextStyle(
                          color: answer.score > 0 ? Colors.green : Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                  ],
                ),
              );
            }).toList(),
            SizedBox(height: 8),
            if (!_isAnswered)
              ElevatedButton(
                onPressed: _selectedAnswers.isNotEmpty ? _submitAnswer : null,
                child: Text('Відповісти'),
              ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quiz_trainer/models/question_model.dart';
import 'package:quiz_trainer/providers/quiz_provider.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:quiz_trainer/screens/question_card.dart';
import 'package:quiz_trainer/screens/search_screen.dart';

class QuizScreen extends StatefulWidget {
  @override
  _QuizScreenState createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  static const _pageSize = 100;

  final PagingController<int, Question> _pagingController = PagingController(firstPageKey: 0);

  late int _currentPage;
  late int _totalPages;

  @override
  void initState() {
    super.initState();
    _currentPage = 0;
    _totalPages = 1;
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    await context.read<QuizProvider>().loadLastResultsFromPrefs();
    _fetchData();
  }

  Future<void> _fetchData() async {
    try {
      await context.read<QuizProvider>().fetchContentData();
      final provider = context.read<QuizProvider>();
      setState(() {
        _totalPages = provider.getTotalPages(_pageSize);
      });
      _fetchPage(0);
    } catch (error) {
      _pagingController.error = error;
    }
  }

  Future<void> _fetchPage(int pageKey) async {
    try {
      final provider = context.read<QuizProvider>();
      final newItems = provider.getQuestionsPage(pageKey, _pageSize);
      final isLastPage = newItems.length < _pageSize;
      if (isLastPage) {
        _pagingController.appendLastPage(newItems);
      } else {
        _pagingController.appendPage(newItems, pageKey + 1);
      }
    } catch (error) {
      _pagingController.error = error;
    }
  }

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });
    _pagingController.refresh();
    _fetchPage(page);
  }

  @override
  void dispose() {
    _pagingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text('Quiz App'),
      actions: [
        IconButton(
          icon: Icon(Icons.search),
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => SearchScreen()),
            );
          },
        ),
        PopupMenuButton<int>(
          onSelected: _onPageChanged,
          itemBuilder: (context) {
            return List.generate(_totalPages, (index) {
              return PopupMenuItem<int>(
                value: index,
                child: Text('Сторінка ${index + 1}'),
              );
            });
          },
          icon: Icon(Icons.more_vert),
        ),
      ],
    ),
    body: PagedListView<int, Question>(
      pagingController: _pagingController,
      builderDelegate: PagedChildBuilderDelegate<Question>(
        itemBuilder: (context, question, index) => QuestionCard(
          question: question,
          questionNumber: index,
        ),
      ),
    ),
  );
}

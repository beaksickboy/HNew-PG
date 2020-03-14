import 'package:rxdart/rxdart.dart';
import 'package:http/http.dart' as http;

import 'dart:collection';
import 'dart:async';

import './article.dart';

enum StoriesType { topStories, newStories }

class NewsBloc {
  var _articles = <Article>[];

  Stream<List<Article>> get articles => _articlesSubject.stream;

  Stream<List<Article>> get topArticles => _topArticlesSubject.stream;

  Stream<List<Article>> get newArticles => _newArticlesSubject.stream;

  final _articlesSubject = BehaviorSubject<UnmodifiableListView<Article>>();

  final _topArticlesSubject = BehaviorSubject<UnmodifiableListView<Article>>();

  final _newArticlesSubject = BehaviorSubject<UnmodifiableListView<Article>>();

  Sink<StoriesType> get storiesType => _storyTypeController.sink;

  final _storyTypeController = StreamController<StoriesType>();

  Stream<bool> get isLoading => _isLoadingSubject.stream;

  final _isLoadingSubject = BehaviorSubject<bool>.seeded(false);

  static const String baseUrl = 'https://hacker-news.firebaseio.com/v0';

  final cachedArticle = HashMap<int, Article>();

  Future<void> initializeArticle() async {
    _getArticles(_topArticlesSubject, await _getIds(StoriesType.topStories));
    _getArticles(_newArticlesSubject, await _getIds(StoriesType.newStories));
  }

  void close() {
    _storyTypeController.close();
  }

  NewsBloc() {
    initializeArticle();

    _storyTypeController.stream.listen((storiesType) async {
      _getArticles(_topArticlesSubject, await _getIds(StoriesType.topStories));
      _getArticles(_newArticlesSubject, await _getIds(StoriesType.newStories));
    });
  }

  _getArticles(BehaviorSubject<UnmodifiableListView<Article>> subject, ids) {
    _isLoadingSubject.add(true);
    _updateArticles(ids).then((_) {
      // _articlesSubject.add(UnmodifiableListView(_articles));
      subject.add(UnmodifiableListView(_articles));
      _isLoadingSubject.add(false);
    });
  }

  Future<Null> _updateArticles(List<int> ids) async {
    final futureArticles = ids.map((id) => _getArticle(id));
    final articles = await Future.wait(futureArticles);
    _articles = articles;
  }

  Future<Article> _getArticle(int id) async {
    if (!cachedArticle.containsKey(id)) {
      final storyRes = await http.get('$baseUrl/item/$id.json');

      if (storyRes.statusCode == 200) {
        cachedArticle[id] = parseArticle(storyRes.body);
      } else {
        throw StateError('Failed Get Article');
      }
    }
    return cachedArticle[id];
  }

  Future<List<int>> _getIds(StoriesType type) async {
    final pieceUrl = type == StoriesType.topStories ? 'top' : 'new';
    final url = '$baseUrl/${pieceUrl}stories.json';
    final response = await http.get(url);
    if (response.statusCode != 200) {
      throw StateError('Can not fetch stories');
    }
    return parseTopStories(response.body).take(10).toList();
  }
}

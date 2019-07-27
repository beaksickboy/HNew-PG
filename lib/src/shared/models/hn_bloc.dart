import 'package:rxdart/rxdart.dart';
import 'package:http/http.dart' as http;

import 'dart:collection';
import 'dart:async';

import './article.dart';

enum StoriesType {
  topStories,
  newStories
}

class NewsBloc {
  var _articles = <Article>[];

  Stream<List<Article>> get articles => _articlesSubject.stream;

  final _articlesSubject = BehaviorSubject<UnmodifiableListView<Article>>();

  Sink<StoriesType> get storiesType => _storyTypeController.sink;

  final _storyTypeController = StreamController<StoriesType>();
  
  
  Stream<bool> get isLoading => _isLoadingSubject.stream;

  final _isLoadingSubject = BehaviorSubject<bool>.seeded(false);

  NewsBloc() {
    _getArticles(_topIds);

    _storyTypeController.stream.listen((storiesType) {
      List<int> ids;
      if (storiesType == StoriesType.newStories) {
        ids = _newIds;
      } else {
        ids = _topIds;
      }
      _getArticles(ids);
    });
  }

  _getArticles(ids) {
    _isLoadingSubject.add(true);
    _updateArticles(ids).then((_) {
      _articlesSubject.add(UnmodifiableListView(_articles));
      _isLoadingSubject.add(false);
    });
  }


  static List<int> _newIds = [
    20496648,
    20495739,
    20496221,
    20497237,
    20495483
  ]; //articles;

  static List<int> _topIds = [
    20493947,
    20496179,
    20490017,
    20494730,
  ];


  Future<Null> _updateArticles(List<int> ids) async {
    final futureArticles = ids.map((id) => _getArticle(id));
    final articles = await Future.wait(futureArticles);
    _articles = articles;
  }


  Future<Article> _getArticle(int id) async {
    final storyRes =
    await http.get('https://hacker-news.firebaseio.com/v0/item/$id.json');
    if (storyRes.statusCode == 200) {
      return parseArticle(storyRes.body);
    }
  }

}
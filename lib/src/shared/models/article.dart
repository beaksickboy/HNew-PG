import 'dart:convert' show jsonDecode;

import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';
import 'package:built_collection/built_collection.dart';

import 'serializers.dart';

part 'article.g.dart';

abstract class Article implements Built<Article, ArticleBuilder> {
  static Serializer<Article> get serializer => _$articleSerializer;
  @nullable
  int get id;

  @nullable
  bool get deleted;

  @nullable
  String get type;

  @nullable
  String get by;

  @nullable
  int get time;

  @nullable
  String get text;

  @nullable
  bool get dead;

  @nullable
  int get parent;

  @nullable
  int get poll;
  BuiltList<int> get kids;

  @nullable
  String get url;

  @nullable
  int get score;

  @nullable
  String get title;

  BuiltList<int> get parts;

  @nullable
  int get descendants;


  Article._();
  factory Article([void Function(ArticleBuilder) updates]) = _$Article;
}


List<int> parseTopStories(String json) {
  final parsed = jsonDecode(json);
  return List<int>.from(parsed);
}

Article parseArticle(String json) {
  final parsed = jsonDecode(json);
  Article article = standardSerializers.deserializeWith(Article.serializer, parsed);
  return article;
}


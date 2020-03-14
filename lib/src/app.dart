import 'package:flutter/material.dart';
import 'package:hacker_new/src/shared/models/hn_bloc.dart';
import 'package:hacker_new/src/widget/search_article.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import './shared/models/article.dart';

import 'dart:collection';

class App extends StatelessWidget {
  final NewsBloc bloc;

  App({Key key, this.bloc}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(
        title: 'Flutter Demo Home Page',
        bloc: bloc,
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final NewsBloc bloc;
  final String title;

  MyHomePage({Key key, this.title, this.bloc}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Flutter Play'),
        leading: LoadingInfo(widget.bloc.isLoading),
        actions: <Widget>[
          Builder(
            builder: (context) => IconButton(
              icon: Icon(Icons.search),
              onPressed: () async {
                final article = await showSearch(
                  context: context,
                  delegate: ArticleSearch(widget.bloc.articles),
                );
                if (article != null) {
                  Scaffold.of(context).showSnackBar(SnackBar(
                    content: Text('Navigate to ${article.url}'),
                  ));
                }
              },
            ),
          )
        ],
      ),
      body: _currentIndex == 0
          ? StreamBuilder<UnmodifiableListView<Article>>(
              stream: widget.bloc.topArticles,
              initialData: UnmodifiableListView<Article>([]),
              builder: (context, snapshot) => ListView(

                // Use to preserver scrolling position
                key: PageStorageKey(_currentIndex),

                children: snapshot.data.map(_article).toList(),
              ),
            )
          : StreamBuilder<UnmodifiableListView<Article>>(
              stream: widget.bloc.newArticles,
              initialData: UnmodifiableListView<Article>([]),
              builder: (context, snapshot) => ListView(
                key: PageStorageKey(_currentIndex),
                children: snapshot.data.map(_article).toList(),
              ),
            ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.keyboard_arrow_up),
            title: Text('Top Stories'),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.new_releases),
            title: Text('New Stories'),
          ),
        ],
        onTap: (index) {
          if (index == 0) {
            widget.bloc.storiesType.add(StoriesType.topStories);
          } else {
            widget.bloc.storiesType.add(StoriesType.newStories);
          }

          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
  Widget _article(Article article) {
    return ExpansionTile(

  /*
   * This widget is typically used with ListView to create an "expand / collapse" list entry.
   *  When used with scrolling widgets like ListView, a unique PageStorageKey must be 
   * specified to enable the ExpansionTile 
   * to save and restore its expanded state when it is scrolled in and out of view.
   */
      key: PageStorageKey(article.title),
      title: Text(
        article.title,
        style: TextStyle(fontSize: 16.0),
        maxLines: 2,
      ),
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Text('${article.descendants} comments'),
            IconButton(
              icon: Icon(Icons.launch),
              onPressed: () async {
                final url = 'http://${article.url}';
                if (await canLaunch(url)) {
                  launch(url);
                }
              },
            )
          ],
        )
      ],
    );
  }
}

class LoadingInfo extends StatefulWidget {
  final Stream<bool> _isLoading;

  LoadingInfo(this._isLoading);

  State<LoadingInfo> createState() => _LoadingInfoState();
}

class _LoadingInfoState extends State<LoadingInfo>
    with TickerProviderStateMixin {
  AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 1),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: widget._isLoading,
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data) {
          _controller.forward();
          return FadeTransition(
            child: Icon(FontAwesomeIcons.hackerNews),
            opacity: Tween(begin: .5, end: 1.0).animate(
                CurvedAnimation(parent: _controller, curve: Curves.easeIn)),
          );
        }
        _controller.reverse();
        return Container();
      },
    );
  }
}

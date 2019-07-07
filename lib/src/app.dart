import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import './shared/models/article.dart';

class App extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final List<Article> _articles = articles;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Flutter Play'),
      ),
      body: RefreshIndicator(
        child: ListView(
          children: _articles.map(_article).toList(),
        ),
        onRefresh: () async {
          await Future.delayed(Duration(seconds: 1));
          setState(() {
            _articles.removeAt(0);
          });
        },
      ),
    );
  }

  Widget _article(Article article) {
    return ExpansionTile(
      key: Key(article.text),
      title: Text(
        article.text,
        style: TextStyle(fontSize: 16.0),
        maxLines: 2,
      ),
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Text('${article.commentsCount} comments'),
            IconButton(
              icon: Icon(Icons.launch),
              onPressed: () async {
                final url = 'http://${article.domain}';
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

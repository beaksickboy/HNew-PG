import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;

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
  final List<int> _ids = [
    20496648,
    20495739,
    20496221,
    20497237,
    20495483,
    20493947,
    20496179,
    20490017,
    20494730,
  ]; //articles;

  Future<Article> _getArticle(int id) async {
    final storyRes =
        await http.get('https://hacker-news.firebaseio.com/v0/item/$id.json');
    if (storyRes.statusCode == 200) {
      return parseArticle(storyRes.body);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Flutter Play'),
        ),
        body: ListView(
          children: _ids
              .map((id) => FutureBuilder<Article>(
                    future: _getArticle(id),
                    builder: (BuildContext context,
                        AsyncSnapshot<Article> snapshot) {
                      if (snapshot.connectionState == ConnectionState.done) {
                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: _article(snapshot.data),
                        );
                      } else {
                        return Center(child: CircularProgressIndicator());
                      }
                    },
                  ))
              .toList(),
        ));
  }

  Widget _article(Article article) {
    return ExpansionTile(
      key: Key(article.title),
      title: Text(
        article.title,
        style: TextStyle(fontSize: 16.0),
        maxLines: 2,
      ),
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            Text('${article.score} comments'),
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

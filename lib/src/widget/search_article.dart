import 'package:flutter/material.dart';
import 'package:hacker_new/src/shared/models/article.dart';
import 'package:url_launcher/url_launcher.dart';

class ArticleSearch extends SearchDelegate<Article> {
  final Stream<List<Article>> articles;

  ArticleSearch(this.articles);

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {},
      )
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        // pass null bcz no info
        close(context, null);
      },
    );
  }

  // Result run when hit enter or hit search icon
  @override
  Widget buildResults(BuildContext context) {
    return StreamBuilder(
      stream: articles,
      builder: (context, AsyncSnapshot<List<Article>> snapshot) {
        if (!snapshot.hasData) {
          return Center(
            child: Text('No Data'),
          );
        }
        // Filter ase on query before return
        // Query is current string in appar filter
        final results = snapshot.data.where(
          (article) => article.title.toLowerCase().contains(query),
        );

        return ListView(
          children: results
              .map((article) => ListTile(
                    leading: Icon(Icons.ac_unit),
                    title: Text('${article.title}'),
                    onTap: () async {
                      if (await canLaunch(article.url)) {
                        launch(article.url);
                      }
                      // Pass article info back
                      close(context, article);
                    },
                  ))
              .toList(),
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return StreamBuilder(
      stream: articles,
      builder: (context, AsyncSnapshot<List<Article>> snapshot) {
        if (!snapshot.hasData) {
          return Center(
            child: Text('No Data'),
          );
        }
        // Filter ase on query before return
        // Query is current string in appar filter
        final results = snapshot.data.where(
          (article) => article.title.toLowerCase().contains(query.toLowerCase()),
        );

        return ListView(
          children: results
              .map((article) => ListTile(
                    // leading: Icon(Icons.ac_unit),
                    title: Text(
                      '${article.title}',
                      style: TextStyle(color: Colors.blue),
                    ),
                  ))
              .toList(),
        );
      },
    );
  }
}

// ignore_for_file: prefer_const_constructors, deprecated_member_use

import 'package:flutter/material.dart';
import './search_page.dart';
import 'package:r_movie/search_card.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import './no_connection.dart';

class MovieList extends StatefulWidget {
  const MovieList({Key? key}) : super(key: key);

  @override
  State<MovieList> createState() => _MovieListState();
}

class _MovieListState extends State<MovieList> {
  final _scroll = ScrollController();
  List<dynamic> movies = [];
  bool _isLoading = true;
  var page = 1;
  final Connectivity _connectivity = Connectivity();
  bool _isConnect = true;

  void checkConnection() async {
    ConnectivityResult connectivityResult =
        await _connectivity.checkConnectivity();

    if (connectivityResult == ConnectivityResult.mobile ||
        connectivityResult == ConnectivityResult.wifi) {
      setState(() {
        getAllMovie();
        _isConnect = true;
      });
    } else {
      setState(() {
        _isConnect = false;
      });
    }
  }

  getAllMovie() async {
    final response = await http.get(
      Uri.parse('https://yts.torrentbay.to/api/v2/list_movies.json?page=$page'),
    );

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      setState(() {
        movies.addAll(data["data"]["movies"]);
        _isLoading = false;
      });
    } else {
      throw Exception('Failed to load Movie');
    }
  }

  @override
  void initState() {
    super.initState();

    _scroll.addListener(() {
      if (_scroll.position.pixels == _scroll.position.maxScrollExtent) {
        setState(() {
          page += 1;
          getAllMovie();
        });
      }
    });

    checkConnection();
  }

  @override
  void dispose() {
    super.dispose();

    _scroll.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.fromLTRB(15, 15, 15, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(
                  height: 40,
                  width: 40,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(50),
                    child: Image.asset(
                      "assets/logo.png",
                      fit: BoxFit.fill,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SearchPage(),
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Icon(
                      Icons.search,
                      color: Colors.orange,
                    ),
                  ),
                ),
              ],
            ),

            // -> End Header

            SizedBox(
              height: 20,
            ),

            Expanded(
              child: _isConnect
                  ? _isLoading
                      ? Center(
                          child: CircularProgressIndicator(),
                        )
                      : ListView.builder(
                          controller: _scroll,
                          itemCount: movies.length + 1,
                          itemBuilder: (BuildContext context, int index) {
                            if (movies.length > index) {
                              return SearchCard(
                                movieId: movies[index]['id'],
                                image: movies[index]['medium_cover_image'],
                                title: movies[index]['title'],
                                year: movies[index]['year'].toString(),
                                genres: movies[index]['genres'] ?? [],
                                rating: movies[index]['rating'].toString(),
                                language: movies[index]['language'],
                                ytTrailerCode: movies[index]['yt_trailer_code'],
                              );
                            } else {
                              return Padding(
                                padding: EdgeInsets.all(10),
                                child: Center(
                                  child: CircularProgressIndicator(),
                                ),
                              );
                            }
                          },
                        )
                  : NoConnection(
                      checkConnection: checkConnection,
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

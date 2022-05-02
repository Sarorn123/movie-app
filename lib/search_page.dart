// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:r_movie/no_connection.dart';
import 'package:r_movie/search_card.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({Key? key}) : super(key: key);
  @override
  _SeachPageState createState() {
    return _SeachPageState();
  }
}

class _SeachPageState extends State<SearchPage> {
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

  final searchKeyword = TextEditingController();

  getAllMovie() async {
    final response = await http.get(
      Uri.parse('https://yts.torrentbay.to/api/v2/list_movies.json?page=$page'),
    );

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      setState(() {
        movies = data["data"]["movies"];
        _isLoading = false;
      });
    } else {
      throw Exception('Failed to load Movie');
    }
  }

  searchMovie() async {
    if (searchKeyword.text != "") {
      setState(() {
        _isLoading = true;
      });
      final response = await http.get(
        Uri.parse(
          'https://yts.torrentbay.to/api/v2/list_movies.json?query_term=' +
              searchKeyword.text,
        ),
      );

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        setState(() {
          movies = data["data"]["movies"] ?? [];
          _isLoading = false;
        });
      } else {
        throw Exception('Failed to load Movie');
      }
    }
  }

  @override
  void initState() {
    super.initState();

    checkConnection();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              // -> Top Box
              Row(
                children: [
                  GestureDetector(
                    onTap: (() => Navigator.pop(context)),
                    child: Container(
                      padding: EdgeInsets.all(13),
                      decoration: BoxDecoration(
                        color: Colors.orange,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.arrow_back_ios,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 5,
                  ),
                  Expanded(
                    child: SizedBox(
                      height: 50,
                      child: TextField(
                        onSubmitted: (value) => searchMovie(),
                        controller: searchKeyword,
                        autofocus: true,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                        ),
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: BorderSide.none,
                          ),
                          fillColor: Colors.orange,
                          filled: true,
                          hintText: 'Search Your Movie',
                          hintStyle: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 5,
                  ),
                  GestureDetector(
                    onTap: searchMovie,
                    child: Container(
                      padding: EdgeInsets.all(13),
                      decoration: BoxDecoration(
                        color: Colors.orange,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        Icons.search,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(
                height: 15,
              ),

              // -> End Search Box

              Expanded(
                child: _isConnect
                    ? _isLoading
                        ? Center(
                            child: CircularProgressIndicator(),
                          )
                        : Container(
                            child: movies.isNotEmpty
                                ? ListView.builder(
                                    itemCount: movies.length,
                                    itemBuilder:
                                        (BuildContext context, int index) {
                                      return SearchCard(
                                        movieId: movies[index]['id'],
                                        image: movies[index]
                                            ['medium_cover_image'],
                                        title: movies[index]['title'],
                                        year: movies[index]['year'].toString(),
                                        genres: movies[index]['genres'] ?? [],
                                        rating:
                                            movies[index]['rating'].toString(),
                                        language: movies[index]['language'],
                                        ytTrailerCode: movies[index]
                                            ['yt_trailer_code'],
                                      );
                                    },
                                  )
                                : SizedBox(
                                    width: double.infinity,
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        SizedBox(
                                          height: 200,
                                          width: 200,
                                          child: SvgPicture.asset(
                                            'assets/empty.svg',
                                          ),
                                        ),
                                        Text(
                                          "No Movie Founded !",
                                          style: GoogleFonts.goldman(
                                            textStyle: TextStyle(
                                              color: Colors.black87,
                                              fontSize: 20,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                          )
                    : NoConnection(checkConnection: checkConnection),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

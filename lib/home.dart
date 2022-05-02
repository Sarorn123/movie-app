// ignore_for_file: prefer_const_constructors, deprecated_member_use

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:r_movie/movie_card%20_horizental.dart';
import 'package:r_movie/movie_card.dart';
import 'package:r_movie/no_connection.dart';
import './search_page.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<dynamic> recommend = [];
  List<dynamic> newest = [];
  List<dynamic> upComming = [];
  final Connectivity _connectivity = Connectivity();
  bool _isConnect = true;

  void checkConnection() async {
    ConnectivityResult connectivityResult =
        await _connectivity.checkConnectivity();

    if (connectivityResult == ConnectivityResult.mobile ||
        connectivityResult == ConnectivityResult.wifi) {
      setState(() {
        recommendMovie();
        fetchMovies();
        _isConnect = true;
      });
    } else {
      setState(() {
        _isConnect = false;
      });
    }
  }

  fetchMovies() async {
    final response = await http.get(
      Uri.parse(
        'https://yts.torrentbay.to/api/v2/list_movies.json?query_term=2022&limit=10&page=1',
      ),
    );

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      setState(() {
        var allMovies = data['data']['movies'];
        newest = [
          allMovies[0],
          allMovies[1],
          allMovies[2],
          allMovies[3],
          allMovies[4]
        ];
        upComming = [
          allMovies[5],
          allMovies[6],
          allMovies[7],
          allMovies[8],
          allMovies[9]
        ];
      });
    } else {
      throw Exception('Failed to load Movie');
    }
  }

  recommendMovie() async {
    final response = await http.get(
      Uri.parse(
        'https://yts.torrentbay.to/api/v2/list_movies.json?query_term=love',
      ),
    );

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      setState(() {
        recommend = data['data']['movies'];
      });
    } else {
      throw Exception('Failed to load Movie');
    }
  }

  @override
  void initState() {
    super.initState();
    checkConnection();
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

            SizedBox(
              height: 20,
            ),

            // Body

            Expanded(
              child: _isConnect
                  ? ListView(
                      children: [
                        Text(
                          'Newest',
                          style: GoogleFonts.goldman(
                            textStyle: TextStyle(
                              color: Colors.black87,
                              fontSize: 23,
                            ),
                          ),
                        ),

                        SizedBox(
                          height: 10,
                        ),

                        SizedBox(
                          height: 300,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: newest.length,
                            itemBuilder: (BuildContext context, int index) {
                              return MovieCard(
                                movieId: newest[index]['id'],
                                title: newest[index]['title'],
                                image: newest[index]['medium_cover_image'],
                                ytTrailerCode: newest[index]['yt_trailer_code'],
                              );
                            },
                          ),
                        ),

                        // -> Upcomming
                        Text(
                          'Upcomming',
                          style: GoogleFonts.goldman(
                            textStyle: TextStyle(
                              color: Colors.black87,
                              fontSize: 23,
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),

                        SizedBox(
                          height: 300,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: upComming.length,
                            itemBuilder: (BuildContext context, int index) {
                              return MovieCard(
                                movieId: upComming[index]['id'],
                                title: upComming[index]['title'],
                                image: upComming[index]['medium_cover_image'],
                                ytTrailerCode: upComming[index]
                                    ['yt_trailer_code'],
                              );
                            },
                          ),
                        ),

                        // -> Latest movie slider

                        Text(
                          'Recommend Movie',
                          style: GoogleFonts.goldman(
                            textStyle: TextStyle(
                              color: Colors.black87,
                              fontSize: 23,
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        recommend.isNotEmpty
                            ? CarouselSlider.builder(
                                options: CarouselOptions(
                                  height: 400,
                                  autoPlay: true,
                                  autoPlayInterval: Duration(seconds: 5),
                                  enlargeCenterPage: true,
                                ),
                                itemCount: recommend.length,
                                itemBuilder: (context, index, realIndex) {
                                  return MovieCardHprizental(
                                    movieId: recommend[index]['id'],
                                    title: recommend[index]['title'],
                                    image: recommend[index]
                                        ['large_cover_image'],
                                    ytTrailerCode: recommend[index]
                                        ['yt_trailer_code'],
                                  );
                                },
                              )
                            : Center(
                                child: CircularProgressIndicator(),
                              ),
                      ],
                    )
                  : NoConnection(checkConnection: checkConnection),
            ),
          ],
        ),
      ),
    );
  }
}

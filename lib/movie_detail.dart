// ignore_for_file: prefer_const_literals_to_create_immutables, unnecessary_const, prefer_const_constructors, deprecated_member_use, non_constant_identifier_names, use_key_in_widget_constructors, prefer_typing_uninitialized_variables

import 'package:flutter/material.dart';
import 'package:r_movie/cast.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'movie_card.dart';

class MovieDetail extends StatefulWidget {
  final int movieId;
  final String ytTrailerCode;
  const MovieDetail({
    required this.movieId,
    required this.ytTrailerCode,
  });

  @override
  State<MovieDetail> createState() => _MovieDetailState();
}

class _MovieDetailState extends State<MovieDetail> {
  var singleMovie;
  List movieImage = [];
  List genres = [];
  List relatedMovie = [];
  bool _isLoading = true;
  final Connectivity _connectivity = Connectivity();
  bool _isConnect = true;
  late YoutubePlayerController _YTcontroller;
  final _scrollController = ScrollController();

  void checkConnection() async {
    ConnectivityResult connectivityResult =
        await _connectivity.checkConnectivity();

    if (connectivityResult == ConnectivityResult.mobile ||
        connectivityResult == ConnectivityResult.wifi) {
      setState(() {
        getMovie();
        _isConnect = true;
      });
    } else {
      setState(() {
        _isConnect = false;
      });
    }
  }

  getMovie() async {
    final response = await http.get(
      Uri.parse(
        'https://yts.torrentbay.to/api/v2/movie_details.json?movie_id=' +
            widget.movieId.toString() +
            '&with_cast=true&with_images=true',
      ),
    );

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      setState(() {
        singleMovie = data['data']['movie'];
        movieImage.add(singleMovie['large_screenshot_image1']!);
        movieImage.add(singleMovie['large_screenshot_image2']!);
        movieImage.add(singleMovie['large_screenshot_image3']!);
        genres = singleMovie['genres'] ?? [];
        if (singleMovie['date_uploaded'] == null) {
          singleMovie['date_uploaded'] = "1876-01-01";
        }
        _isLoading = false;
      });
    } else {
      throw Exception('Failed to load Movie');
    }
  }

  getRelatedMovie() async {
    final response = await http.get(
      Uri.parse(
        'https://yts.torrentbay.to/api/v2/movie_suggestions.json?movie_id=' +
            widget.movieId.toString(),
      ),
    );

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      setState(() {
        relatedMovie = data['data']['movies'];
      });
    } else {
      throw Exception('Failed to load Movie');
    }
  }

  @override
  void initState() {
    super.initState();
    checkConnection();
    _YTcontroller = YoutubePlayerController(
      initialVideoId: widget.ytTrailerCode,
      flags: YoutubePlayerFlags(
        autoPlay: true,
        mute: false,
        loop: true,
      ),
    );

    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        setState(() {
          getRelatedMovie();
        });
      }
    });
  }

  _launchURL(String URL) async {
    if (await canLaunch(URL)) {
      await launch(URL);
    } else {
      throw 'Could not launch $URL';
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: _isConnect
            ? _isLoading
                ? Center(
                    child: CircularProgressIndicator(),
                  )
                : ListView(
                    controller: _scrollController,
                    children: [
                      Column(
                        children: [
                          // -> Cover Image
                          Stack(
                            children: [
                              SizedBox(
                                width: double.infinity,
                                child: YoutubePlayerBuilder(
                                  player: YoutubePlayer(
                                    controller: _YTcontroller,
                                    progressIndicatorColor: Colors.orange,
                                    showVideoProgressIndicator: true,
                                  ),
                                  builder: (context, player) {
                                    return Column(
                                      children: [
                                        player,
                                      ],
                                    );
                                  },
                                ),
                              ),
                              SizedBox(
                                height: 230,
                                child: Align(
                                  child: Padding(
                                    padding: EdgeInsets.fromLTRB(20, 20, 0, 0),
                                    child: GestureDetector(
                                      child: Container(
                                        padding: EdgeInsets.all(5),
                                        child: Icon(
                                          Icons.arrow_back_ios,
                                          color: Colors.orange,
                                        ),
                                      ),
                                      onTap: () {
                                        Navigator.pop(context);
                                      },
                                    ),
                                  ),
                                  alignment: Alignment.topLeft,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(
                            height: 10,
                          ),

                          // -> Profile Title

                          Container(
                            margin: const EdgeInsets.symmetric(horizontal: 10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  singleMovie['title_long'],
                                  style: GoogleFonts.goldman(
                                    textStyle: TextStyle(
                                      color: Colors.black87,
                                      fontSize: 20,
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  height: 10,
                                ),
                                Row(
                                  children: [
                                    SizedBox(
                                      height: 100,
                                      width: 100,
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(50),
                                        child: Image.network(
                                          singleMovie['medium_cover_image'],
                                          fit: BoxFit.fill,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(
                                      width: 10,
                                    ),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const SizedBox(
                                          height: 5,
                                        ),
                                        Text(
                                          singleMovie['runtime'].toString() +
                                              " minuts" +
                                              " | " +
                                              DateFormat('dd-MM-yyyy').format(
                                                DateTime.parse(singleMovie[
                                                    'date_uploaded']),
                                              ),
                                          style: TextStyle(
                                            fontSize: 15,
                                            color: Colors.black38,
                                          ),
                                        ),
                                        SizedBox(
                                          height: 20,
                                          child: Row(
                                            children: genres
                                                .map(
                                                  (item) => Text(
                                                    item + " ",
                                                    style: TextStyle(
                                                      color: Colors.orange,
                                                      fontSize: 15,
                                                    ),
                                                  ),
                                                )
                                                .toList(),
                                          ),
                                        ),
                                        Text(
                                          singleMovie['language'].toUpperCase(),
                                          style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.orange,
                                          ),
                                        ),
                                        Text(
                                          singleMovie['rating'].toString(),
                                          textAlign: TextAlign.end,
                                          style: GoogleFonts.goldman(
                                            textStyle: TextStyle(
                                              color: Colors.orange,
                                              fontSize: 23,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),

                                SizedBox(
                                  height: 15,
                                ),

                                // -> Detail

                                Text(
                                  'Description',
                                  style: GoogleFonts.goldman(
                                    textStyle: TextStyle(
                                      color: Colors.black87,
                                      fontSize: 20,
                                    ),
                                  ),
                                ),

                                SizedBox(
                                  height: 15,
                                ),

                                Text(
                                  singleMovie['description_full'],
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: Colors.black38,
                                  ),
                                ),

                                SizedBox(
                                  height: 15,
                                ),

                                // -> Casts

                                Text(
                                  'Cast',
                                  style: GoogleFonts.goldman(
                                    textStyle: TextStyle(
                                      color: Colors.black87,
                                      fontSize: 20,
                                    ),
                                  ),
                                ),

                                SizedBox(
                                  height: 15,
                                ),

                                SizedBox(
                                  height: 120,
                                  child: singleMovie['cast'] != null
                                      ? ListView.builder(
                                          scrollDirection: Axis.horizontal,
                                          itemCount: singleMovie['cast'].length,
                                          itemBuilder: (BuildContext context,
                                              int index) {
                                            return CastCard(
                                              name: singleMovie['cast'][index]
                                                  ['name'],
                                              character_name:
                                                  singleMovie['cast'][index]
                                                      ['character_name'],
                                              image: singleMovie['cast'][index]
                                                      ['url_small_image'] ??
                                                  "",
                                            );
                                          },
                                        )
                                      : Text(""),
                                ),

                                // -> Image Screenshort

                                Text(
                                  'Movie Image',
                                  style: GoogleFonts.goldman(
                                    textStyle: TextStyle(
                                      color: Colors.black87,
                                      fontSize: 20,
                                    ),
                                  ),
                                ),

                                SizedBox(
                                  height: 15,
                                ),

                                CarouselSlider.builder(
                                  options: CarouselOptions(
                                    height: 200,
                                    viewportFraction: 1,
                                    autoPlay: true,
                                    autoPlayInterval: Duration(seconds: 3),
                                    enlargeCenterPage: true,
                                  ),
                                  itemCount: movieImage.length,
                                  itemBuilder: (context, index, realIndex) {
                                    final image = movieImage[index];
                                    return SizedBox(
                                      width: 400,
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(15),
                                        child: Image.network(
                                          image,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    );
                                  },
                                ),

                                SizedBox(
                                  height: 15,
                                ),

                                // -> Image Screenshort

                                Text(
                                  'More Info',
                                  style: GoogleFonts.goldman(
                                    textStyle: TextStyle(
                                      color: Colors.black87,
                                      fontSize: 20,
                                    ),
                                  ),
                                ),

                                SizedBox(
                                  height: 15,
                                ),

                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.orange,
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  padding: EdgeInsets.all(10),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Column(
                                        children: [
                                          GestureDetector(
                                            onTap: () {},
                                            child: Icon(
                                              Icons.favorite,
                                              color: Colors.white,
                                            ),
                                          ),
                                          Text(
                                            singleMovie['like_count']
                                                .toString(),
                                            style: TextStyle(
                                              color: Colors.white,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Column(
                                        children: [
                                          GestureDetector(
                                            onTap: () {},
                                            child: Icon(
                                              Icons.rate_review,
                                              color: Colors.white,
                                            ),
                                          ),
                                          Text(
                                            singleMovie['mpa_rating']
                                                .toString(),
                                            style: TextStyle(
                                              color: Colors.white,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Column(
                                        children: [
                                          GestureDetector(
                                            child: Icon(
                                              Icons.download,
                                              color: Colors.white,
                                            ),
                                            onTap: () {
                                              showModalBottomSheet(
                                                context: context,
                                                builder: (contex) {
                                                  return Container(
                                                    decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.only(
                                                        topRight:
                                                            Radius.circular(20),
                                                        topLeft:
                                                            Radius.circular(20),
                                                      ),
                                                    ),
                                                    child: ListView.separated(
                                                      shrinkWrap: true,
                                                      itemCount: singleMovie[
                                                              "torrents"]
                                                          .length,
                                                      separatorBuilder:
                                                          (BuildContext context,
                                                              int index) {
                                                        return SizedBox(
                                                            height: 0);
                                                      },
                                                      itemBuilder:
                                                          (context, index) {
                                                        var quality =
                                                            singleMovie[
                                                                    "torrents"]
                                                                [index];
                                                        return ListTile(
                                                          leading: Icon(
                                                            Icons.download,
                                                            color:
                                                                Colors.orange,
                                                          ),
                                                          title: Text(
                                                            quality["quality"] +
                                                                " 👉 " +
                                                                quality['size'],
                                                          ),
                                                          onTap: () {
                                                            _launchURL(
                                                              quality["url"],
                                                            );
                                                          },
                                                        );
                                                      },
                                                    ),
                                                  );
                                                },
                                              );
                                            },
                                          ),
                                          Text(
                                            singleMovie['download_count']
                                                .toString(),
                                            style: TextStyle(
                                              color: Colors.white,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(
                                  height: 20,
                                ),

                                Text(
                                  'Suggestions',
                                  style: GoogleFonts.goldman(
                                    textStyle: TextStyle(
                                      color: Colors.black87,
                                      fontSize: 20,
                                    ),
                                  ),
                                ),

                                SizedBox(
                                  height: 20,
                                ),

                                relatedMovie.isNotEmpty
                                    ? SizedBox(
                                        height: 300,
                                        child: ListView.builder(
                                          scrollDirection: Axis.horizontal,
                                          itemCount: relatedMovie.length,
                                          itemBuilder: (BuildContext context,
                                              int index) {
                                            return MovieCard(
                                              movieId: relatedMovie[index]
                                                  ['id'],
                                              title: relatedMovie[index]
                                                  ['title'],
                                              image: relatedMovie[index]
                                                  ['medium_cover_image'],
                                              ytTrailerCode: relatedMovie[index]
                                                  ['yt_trailer_code'],
                                            );
                                          },
                                        ),
                                      )
                                    : Center(
                                        child: CircularProgressIndicator(),
                                      ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  )
            : SizedBox(
                width: double.infinity,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Column(
                      children: [
                        Text(
                          "NO INTERNET CONNECTION",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        RaisedButton(
                          color: Colors.orange,
                          onPressed: checkConnection,
                          child: Text(
                            "Retry",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}

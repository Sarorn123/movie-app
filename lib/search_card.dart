// ignore_for_file: use_key_in_widget_constructors, prefer_const_constructors

import 'package:flutter/material.dart';

import 'package:google_fonts/google_fonts.dart';
import 'package:r_movie/movie_detail.dart';

class SearchCard extends StatelessWidget {
  final int movieId;
  final String image;
  final String title;
  final String year;
  final List genres;
  final String rating;
  final String language;
  final String ytTrailerCode;

  const SearchCard({
    required this.movieId,
    required this.image,
    required this.title,
    required this.year,
    required this.genres,
    required this.rating,
    required this.language,
    required this.ytTrailerCode,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MovieDetail(
              movieId: movieId,
              ytTrailerCode: ytTrailerCode,
            ),
          ),
        );
      },
      child: Container(
        color: Colors.transparent,
        width: double.infinity,
        margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
        child: Row(
          children: [
            SizedBox(
              height: 140,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.network(
                  image,
                ),
              ),
            ),
            SizedBox(
              width: 10,
            ),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.goldman(
                      textStyle: TextStyle(
                        color: Colors.black87,
                        fontSize: 15,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Text(
                    year,
                    style: TextStyle(
                      color: Colors.orange,
                      fontSize: 15,
                    ),
                  ),
                  Row(
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
                  Container(
                    padding: EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(10),
                        bottomRight: Radius.circular(10),
                        bottomLeft: Radius.circular(10),
                      ),
                    ),
                    child: Text(
                      rating,
                      style: GoogleFonts.goldman(
                        textStyle: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                  Text(
                    language,
                    style: TextStyle(
                      color: Colors.orange,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

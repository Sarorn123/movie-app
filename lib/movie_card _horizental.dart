// ignore_for_file: use_key_in_widget_constructors, prefer_const_constructors, file_names

import 'package:flutter/material.dart';
import './movie_detail.dart';

class MovieCardHprizental extends StatelessWidget {
  final String title;
  final String image;
  final int movieId;
  final String ytTrailerCode;

  const MovieCardHprizental({
    required this.movieId,
    required this.title,
    required this.image,
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
        margin: EdgeInsets.all(5),
        width: 300,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: Image.network(
            image,
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}

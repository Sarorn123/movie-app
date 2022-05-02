class Movie {
  final int id;
  final String title;
  final String backgroundImage;

  const Movie({
    required this.id,
    required this.title,
    required this.backgroundImage,
  });

  factory Movie.fromJson(Map<String, dynamic> json) {
    final movie = json['data']['movie'];
    return Movie(
      id: movie['id'],
      title: movie['title'],
      backgroundImage: movie['medium_cover_image'],
    );
  }
}

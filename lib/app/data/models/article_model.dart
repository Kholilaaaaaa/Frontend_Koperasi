class ArticleModel {
  final String title;
  final String description;
  final String link;
  final String pubDateStr;
  final String thumbnailUrl;
  final String source;

  ArticleModel({
    required this.title,
    required this.description,
    required this.link,
    required this.pubDateStr,
    required this.thumbnailUrl,
    required this.source,
  });

  factory ArticleModel.fromJson(Map<String, dynamic> json) {
    return ArticleModel(
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      link: json['link'] ?? '',
      pubDateStr: json['pub_date_str'] ?? '',
      thumbnailUrl: json['thumbnail_url'] ?? '',
      source: json['source'] ?? '',
    );
  }
}

// NewsResponse
class NewsModel {
  final int id;
  final String title;
  final String summary;
  final String? link;
  final String backgroundImageUrl;

  const NewsModel({
    required this.id,
    required this.title,
    required this.summary,
    required this.link,
    required this.backgroundImageUrl,
  });

  factory NewsModel.fromJson(Map<String, dynamic> json) {
    return NewsModel(
      id:                 json['id']                 as int,
      title:              json['title']              as String,
      summary:            json['summary']            as String,
      link:               json['link']               as String?,
      backgroundImageUrl: json['backgroundImageUrl'] as String,
    );
  }
}
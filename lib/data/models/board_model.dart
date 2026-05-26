// [ADDED] 게시판 관련 데이터 모델
// GET  /api/v1/board/posts
// POST /api/v1/board/posts
// GET  /api/v1/board/posts/{postId}
// GET  /api/v1/board/posts/{postId}/fraud-vote
// GET  /api/v1/board/posts/{postId}/comments

// ── 게시글 카테고리 ──
enum BoardCategory {
  experience('EXPERIENCE', '경험담'),
  fraudVote('FRAUD_VOTE', '사기 의심 투표'),
  analysisShare('AI_ANALYSIS', '분석 결과 공유');

  final String value;
  final String label;
  const BoardCategory(this.value, this.label);

  static BoardCategory? fromValue(String? value) {
    if (value == null) return null;
    for (final c in BoardCategory.values) {
      if (c.value == value) return c;
    }
    return null;
  }
}

// ── 게시글 목록 아이템 모델 ──
class BoardPostListItemModel {
  final int            id;
  final BoardCategory? category;
  final String         title;
  final int            scrapCount;
  final int            commentCount;
  final bool           isScrapped;
  final DateTime       createdAt;

  const BoardPostListItemModel({
    required this.id,
    required this.category,
    required this.title,
    required this.scrapCount,
    required this.commentCount,
    required this.isScrapped,
    required this.createdAt,
  });

  factory BoardPostListItemModel.fromJson(Map<String, dynamic> json) {
    return BoardPostListItemModel(
      id:           json['id'] as int,
      category:     BoardCategory.fromValue(json['category'] as String?),
      title:        json['title'] as String? ?? '',
      scrapCount:   json['scrapCount'] as int? ?? 0,
      commentCount: json['commentCount'] as int? ?? 0,
      isScrapped:   json['isScrapped'] as bool? ?? false,
      createdAt:    DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
    );
  }
}

// ── 게시글 목록 페이지네이션 결과 ──
class BoardPostListResult {
  final List<BoardPostListItemModel> data;
  final int?  nextCursor;
  final bool  hasNext;

  const BoardPostListResult({
    required this.data,
    required this.nextCursor,
    required this.hasNext,
  });

  factory BoardPostListResult.fromJson(Map<String, dynamic> json) {
    final rawList = json['data'] as List<dynamic>? ?? [];
    return BoardPostListResult(
      data:       rawList.map((e) => BoardPostListItemModel.fromJson(e as Map<String, dynamic>)).toList(),
      nextCursor: json['nextCursor'] as int?,
      hasNext:    json['hasNext'] as bool? ?? false,
    );
  }
}

// ── 게시글 상세 모델 ──
class BoardPostDetailModel {
  final int            id;
  final BoardCategory? category;
  final String         title;
  final String         content;
  final String         authorNickname;
  final int            scrapCount;
  final int            commentCount;
  final bool           isScrapped;
  final List<String>   imageUrls;
  final int?           analysisItemId;
  final DateTime       createdAt;

  const BoardPostDetailModel({
    required this.id,
    required this.category,
    required this.title,
    required this.content,
    required this.authorNickname,
    required this.scrapCount,
    required this.commentCount,
    required this.isScrapped,
    required this.imageUrls,
    required this.analysisItemId,
    required this.createdAt,
  });

  factory BoardPostDetailModel.fromJson(Map<String, dynamic> json) {
    final rawUrls = json['imageUrls'] as List<dynamic>? ?? [];
    return BoardPostDetailModel(
      id:             json['id'] as int,
      category:       BoardCategory.fromValue(json['category'] as String?),
      title:          json['title'] as String? ?? '',
      content:        json['content'] as String? ?? '',
      authorNickname: json['authorNickname'] as String? ?? '',
      scrapCount:     json['scrapCount'] as int? ?? 0,
      commentCount:   json['commentCount'] as int? ?? 0,
      isScrapped:     json['isScrapped'] as bool? ?? false,
      imageUrls:      rawUrls.map((e) => e as String).toList(),
      analysisItemId: json['analysisItemId'] as int?,
      createdAt:      DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
    );
  }
}

// ── 사기 의심 투표 결과 모델 ──
class BoardFraudVoteModel {
  final int postId;
  final int fraudCount;
  final int notFraudCount;
  final bool isVoted;

  const BoardFraudVoteModel({
    required this.postId,
    required this.fraudCount,
    required this.notFraudCount,
    required this.isVoted,
  });

  factory BoardFraudVoteModel.fromJson(Map<String, dynamic> json) {
    return BoardFraudVoteModel(
      postId:        json['postId'] as int,
      fraudCount:    json['fraudCount'] as int? ?? 0,
      notFraudCount: json['notFraudCount'] as int? ?? 0,
      isVoted:       json['isVoted'] as bool? ?? false,
    );
  }

  int get total => fraudCount + notFraudCount;
  double get fraudRatio    => total == 0 ? 0 : fraudCount    / total;
  double get notFraudRatio => total == 0 ? 0 : notFraudCount / total;
}

// ── 대댓글 모델 ──
class BoardReplyModel {
  final int      id;
  final String   content;
  final String   authorNickname;
  final DateTime createdAt;

  const BoardReplyModel({
    required this.id,
    required this.content,
    required this.authorNickname,
    required this.createdAt,
  });

  factory BoardReplyModel.fromJson(Map<String, dynamic> json) {
    return BoardReplyModel(
      id:             json['id'] as int,
      content:        json['content'] as String? ?? '',
      authorNickname: json['authorNickname'] as String? ?? '',
      createdAt:      DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
    );
  }
}

// ── 댓글 모델 ──
class BoardCommentModel {
  final int                  id;
  final String               content;
  final String               authorNickname;
  final DateTime             createdAt;
  final List<BoardReplyModel> replies;

  const BoardCommentModel({
    required this.id,
    required this.content,
    required this.authorNickname,
    required this.createdAt,
    required this.replies,
  });

  factory BoardCommentModel.fromJson(Map<String, dynamic> json) {
    final rawReplies = json['replies'] as List<dynamic>? ?? [];
    return BoardCommentModel(
      id:             json['id'] as int,
      content:        json['content'] as String? ?? '',
      authorNickname: json['authorNickname'] as String? ?? '',
      createdAt:      DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
      replies:        rawReplies.map((e) => BoardReplyModel.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }
}

// ── 게시글 등록 요청 모델 ──
class BoardPostCreateRequest {
  final String       category;
  final String       title;
  final String       content;
  final List<String> imageNames;
  final int?         analysisItemId;

  const BoardPostCreateRequest({
    required this.category,
    required this.title,
    required this.content,
    required this.imageNames,
    this.analysisItemId,
  });

  Map<String, dynamic> toJson() => {
    'category':       category,
    'title':          title,
    'content':        content,
    'imageNames':     imageNames,
    if (analysisItemId != null) 'analysisItemId': analysisItemId,
  };
}
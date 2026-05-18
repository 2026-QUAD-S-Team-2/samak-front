// [ADDED] 게시판 관련 Repository
import '../../core/network/dio_client.dart';
import '../models/board_model.dart'; // ✅ 경로 수정

class BoardRepository {
  BoardRepository._();
  static final BoardRepository instance = BoardRepository._();

  /// 게시글 목록 조회
  Future<BoardPostListResult> getPosts({ // ✅ BoardPostPage → BoardPostListResult
    String? category,
    int? cursor,
    int size = 10,
  }) async {
    final data = await DioClient.instance.get(
      '/api/v1/board/posts',
      queryParameters: {
        if (category != null) 'category': category,
        if (cursor != null) 'cursor': cursor,
        'size': size,
      },
    );
    return BoardPostListResult.fromJson(data as Map<String, dynamic>);
  }

  /// 게시글 등록
  Future<void> createPost(BoardPostCreateRequest request) async {
    await DioClient.instance.post(
      '/api/v1/board/posts',
      data: request.toJson(),
    );
  }

  /// 게시글 상세 조회 (별칭 추가로 board_detail.dart 호환)
  Future<BoardPostDetailModel> getPost(int postId) => getPostDetail(postId); // ✅ 별칭

  Future<BoardPostDetailModel> getPostDetail(int postId) async { // ✅ BoardPostDetail → BoardPostDetailModel
    final data = await DioClient.instance.get('/api/v1/board/posts/$postId');
    return BoardPostDetailModel.fromJson(data as Map<String, dynamic>);
  }

  /// 스크랩 추가 (별칭 추가로 board_detail.dart 호환)
  Future<int> addScrap(int postId) async {
    final data = await DioClient.instance.post(
      '/api/v1/board/posts/$postId/scrap',
    );
    return (data as Map<String, dynamic>)['scrapCount'] as int;
  }

  Future<void> scrapPost(int postId) async {
    await DioClient.instance.post('/api/v1/board/posts/$postId/scrap');
  }

  /// 스크랩 취소 (별칭 추가로 board_detail.dart 호환)
  Future<int> removeScrap(int postId) async {
    final data = await DioClient.instance.delete(
      '/api/v1/board/posts/$postId/scrap',
    );
    return (data as Map<String, dynamic>)['scrapCount'] as int;
  }

  Future<void> unscrapPost(int postId) async {
    await DioClient.instance.delete('/api/v1/board/posts/$postId/scrap');
  }

  /// 사기 의심 투표 결과 조회
  Future<BoardFraudVoteModel> getFraudVote(int postId) async { // ✅ FraudVoteResult → BoardFraudVoteModel
    final data = await DioClient.instance.get('/api/v1/board/posts/$postId/fraud-vote');
    return BoardFraudVoteModel.fromJson(data as Map<String, dynamic>);
  }

  /// 사기 의심 투표 (별칭 추가로 board_detail.dart 호환)
  Future<void> vote(int postId, String voteType) => castFraudVote(postId, voteType: voteType); // ✅ 별칭

  Future<void> castFraudVote(int postId, {required String voteType}) async {
    await DioClient.instance.post(
      '/api/v1/board/posts/$postId/fraud-vote',
      data: {'voteType': voteType},
    );
  }

  /// 댓글 목록 조회
  Future<List<BoardCommentModel>> getComments(int postId) async { // ✅ BoardComment → BoardCommentModel
    final data = await DioClient.instance.get('/api/v1/board/posts/$postId/comments');
    return (data as List)
        .map((e) => BoardCommentModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// 댓글 작성
  Future<BoardCommentModel> createComment(int postId, String content) async { // ✅ BoardComment → BoardCommentModel
    final data = await DioClient.instance.post(
      '/api/v1/board/posts/$postId/comments',
      data: {'content': content},
    );
    final json = data as Map<String, dynamic>;
    return BoardCommentModel(
      id:             json['id'] as int,
      content:        json['content'] as String,
      authorNickname: json['authorNickname'] as String,
      createdAt:      DateTime.parse(json['createdAt'] as String),
      replies:        [],
    );
  }

  /// 대댓글 작성
  Future<BoardReplyModel> createReply( // ✅ BoardReply → BoardReplyModel
      int postId,
      int commentId,
      String content,
      ) async {
    final data = await DioClient.instance.post(
      '/api/v1/board/posts/$postId/comments/$commentId/replies',
      data: {'content': content},
    );
    return BoardReplyModel.fromJson(data as Map<String, dynamic>);
  }
}
// [ADDED] 게시글 상세 조회 화면
// GET  /api/v1/board/posts/{postId}          — 게시글 상세
// GET  /api/v1/board/posts/{postId}/comments — 댓글 목록
// POST /api/v1/board/posts/{postId}/scrap    — 스크랩 추가
// DELETE /api/v1/board/posts/{postId}/scrap  — 스크랩 취소
// GET  /api/v1/board/posts/{postId}/fraud-vote  — 투표 결과 (FRAUD_VOTE 카테고리만)
// POST /api/v1/board/posts/{postId}/fraud-vote  — 투표 (FRAUD_VOTE 카테고리만)
// POST /api/v1/board/posts/{postId}/comments              — 댓글 작성
// POST /api/v1/board/posts/{postId}/comments/{id}/replies — 대댓글 작성
import 'package:flutter/material.dart';
import '../core/design_system/app_colors.dart';
import '../core/design_system/app_dimensions.dart';
import '../core/design_system/app_text_styles.dart';
import '../core/design_system/widgets/app_header.dart';
import '../core/design_system/widgets/app_dialog.dart';
import '../data/repositories/board_repository.dart';
import '../data/repositories/member_repository.dart';
import '../data/models/board_model.dart';
import '../core/network/api_exception.dart';
import '../screens/profile_screen.dart';

class BoardDetailScreen extends StatefulWidget {
  final int postId;
  const BoardDetailScreen({super.key, required this.postId});

  @override
  State<BoardDetailScreen> createState() => _BoardDetailScreenState();
}

class _BoardDetailScreenState extends State<BoardDetailScreen> {
  BoardPostDetailModel?   _post;
  List<BoardCommentModel> _comments = [];
  BoardFraudVoteModel?    _fraudVote;
  bool _isLoading   = true;
  bool _isScrapped  = false; // 스크랩 상태 (서버 응답 없으므로 낙관적 토글)
  int  _scrapCount  = 0;
  bool _hasVoted    = false; // 투표 완료 여부
  String? _profileImageUrl;

  // 댓글/대댓글 입력
  final TextEditingController _commentController = TextEditingController();
  bool _isSubmittingComment = false;
  int? _replyTargetCommentId; // null이면 댓글, non-null이면 대댓글
  String _replyTargetNickname = '';

  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _loadAll() async {
    setState(() => _isLoading = true);
    try {
      // 프로필 로드 (실패해도 무시)
      try {
        final member = await MemberRepository.instance.getMe();
        if (mounted) setState(() => _profileImageUrl = member.profileImageUrl);
      } catch (_) {}

      final post     = await BoardRepository.instance.getPost(widget.postId);
      final comments = await BoardRepository.instance.getComments(widget.postId);

      BoardFraudVoteModel? fraudVote;
      if (post.category == BoardCategory.fraudVote) {
        fraudVote = await BoardRepository.instance.getFraudVote(widget.postId);
      }

      if (mounted) {
        setState(() {
          _post      = post;
          _comments  = comments;
          _fraudVote = fraudVote;
          _scrapCount = post.scrapCount;
          _isScrapped = post.isScrapped;
        });
      }
    } on ApiException catch (e) {
      if (mounted) {
        AppDialog.show(context, title: '불러오기 실패', message: e.message);
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ── 스크랩 토글 ──
  Future<void> _toggleScrap() async {
    final prev = _isScrapped;
    setState(() => _isScrapped = !_isScrapped);
    try {
      final updatedCount = !prev
          ? await BoardRepository.instance.addScrap(widget.postId)
          : await BoardRepository.instance.removeScrap(widget.postId);
      if (mounted) setState(() => _scrapCount = updatedCount);
    } on ApiException catch (e) {
      if (mounted) {
        setState(() {
          _isScrapped = prev;
          _scrapCount = _post!.scrapCount;
        });
        AppDialog.show(context, title: '스크랩 실패', message: e.message);
      }
    }
  }

  // ── 사기 의심 투표 ──
  Future<void> _vote(String voteType) async {
    try {
      await BoardRepository.instance.vote(widget.postId, voteType);
      if (!mounted) return;
      setState(() => _hasVoted = true);
      // 투표 후 결과 갱신
      final updated = await BoardRepository.instance.getFraudVote(widget.postId);
      if (mounted) setState(() => _fraudVote = updated);
    } on ApiException catch (e) {
      if (mounted) {
        AppDialog.show(context, title: '투표 실패', message: e.message);
      }
    }
  }

  // ── 댓글 또는 대댓글 제출 ──
  Future<void> _submitComment() async {
    final text = _commentController.text.trim();
    if (text.isEmpty) return;

    setState(() => _isSubmittingComment = true);
    try {
      if (_replyTargetCommentId == null) {
        // 댓글 작성
        final newComment = await BoardRepository.instance.createComment(
          widget.postId,
          text,
        );
        if (mounted) {
          setState(() {
            _comments.add(newComment);
            _commentController.clear();
          });
        }
      } else {
        // 대댓글 작성
        final newReply = await BoardRepository.instance.createReply(
          widget.postId,
          _replyTargetCommentId!,
          text,
        );
        if (mounted) {
          setState(() {
            final idx = _comments.indexWhere((c) => c.id == _replyTargetCommentId);
            if (idx != -1) {
              final old = _comments[idx];
              _comments[idx] = BoardCommentModel(
                id:             old.id,
                content:        old.content,
                authorNickname: old.authorNickname,
                createdAt:      old.createdAt,
                replies:        [...old.replies, newReply],
              );
            }
            _commentController.clear();
            _replyTargetCommentId   = null;
            _replyTargetNickname    = '';
          });
        }
      }
    } on ApiException catch (e) {
      if (mounted) {
        AppDialog.show(context, title: '작성 실패', message: e.message);
      }
    } finally {
      if (mounted) setState(() => _isSubmittingComment = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppHeader(
        title:          '게시글',
        showBackButton: true,
        onBack:         () => Navigator.of(context).maybePop(),
        profileImageUrl: _profileImageUrl,
        onProfileTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const ProfileScreen()),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : _post == null
          ? Center(
        child: Text(
          '게시글을 불러올 수 없습니다.',
          style: AppTypography.middle14.copyWith(color: AppColors.gray500),
        ),
      )
          : Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(AppDimensions.screenPadding),
              children: [
                // ── 게시글 본문 카드 ──
                _PostBodyCard(
                  post:        _post!,
                  isScrapped:  _isScrapped,
                  scrapCount:  _scrapCount, // [ADDED]
                  onScrapTap:  _toggleScrap,
                ),

                const SizedBox(height: 12),

                // ── 사기 의심 투표 카드 (FRAUD_VOTE 카테고리만) ──
                if (_post!.category == BoardCategory.fraudVote)
                  _FraudVoteCard(
                    voteResult: _fraudVote,
                    hasVoted:   _hasVoted,
                    onVote:     _vote,
                  ),

                if (_post!.category == BoardCategory.fraudVote)
                  const SizedBox(height: 12),

                // ── 댓글 목록 ──
                _CommentsSection(
                  comments: _comments,
                  onReplyTap: (commentId, nickname) {
                    setState(() {
                      _replyTargetCommentId = commentId;
                      _replyTargetNickname  = nickname;
                    });
                    FocusScope.of(context).requestFocus(FocusNode());
                  },
                ),
              ],
            ),
          ),

          // ── 댓글 입력 바 ──
          _CommentInputBar(
            controller:    _commentController,
            isSubmitting:  _isSubmittingComment,
            replyTarget:   _replyTargetNickname.isNotEmpty
                ? _replyTargetNickname
                : null,
            onCancelReply: () => setState(() {
              _replyTargetCommentId = null;
              _replyTargetNickname  = '';
            }),
            onSubmit: _submitComment,
          ),
        ],
      ),
    );
  }
}

// ── 게시글 본문 카드 ──
class _PostBodyCard extends StatelessWidget {
  final BoardPostDetailModel post;
  final bool         isScrapped;
  final int          scrapCount; // [ADDED]
  final VoidCallback onScrapTap;

  const _PostBodyCard({
    required this.post,
    required this.isScrapped,
    required this.scrapCount, // [ADDED]
    required this.onScrapTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color:        Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 카테고리 배지 + 스크랩 버튼
          Row(
            children: [
              if (post.category != null) _CategoryBadge(category: post.category!),
              const Spacer(),
              GestureDetector(
                onTap: onScrapTap,
                child: Row(
                  children: [
                    Icon(
                      isScrapped ? Icons.bookmark : Icons.bookmark_border,
                      color: isScrapped ? AppColors.primary : AppColors.gray500,
                      size: 24,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '$scrapCount',
                      style: AppTypography.small12.copyWith(
                        color: isScrapped ? AppColors.primary : AppColors.gray500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // 제목
          Text(
            post.title,
            style: AppTypography.largeBold16.copyWith(letterSpacing: -0.5),
          ),
          const SizedBox(height: 6),

          // 작성자 + 날짜
          // [MODIFIED] thumb_up + likeCount 제거, commentCount만 유지
          // [MODIFIED] thumb_up + likeCount 제거, commentCount만 유지
          Row(
            children: [
              Text(
                post.authorNickname,
                style: AppTypography.small12.copyWith(color: AppColors.gray500),
              ),
              const SizedBox(width: 8),
              Text(
                _formatDate(post.createdAt),
                style: AppTypography.small12.copyWith(color: AppColors.gray500),
              ),
              const Spacer(),
              Icon(Icons.chat_bubble_outline, size: 14, color: AppColors.gray500),
              const SizedBox(width: 4),
              Text(
                '${post.commentCount}',
                style: AppTypography.small12.copyWith(color: AppColors.gray500),
              ),
            ],
          ),

          const Divider(height: 24, color: AppColors.gray200),

          // 본문
          Text(
            post.content,
            style: AppTypography.middle14.copyWith(height: 1.7),
          ),

          // 이미지 (있는 경우)
          if (post.imageUrls.isNotEmpty) ...[
            const SizedBox(height: 16),
            SizedBox(
              height: 180,
              child: ListView.separated(
                scrollDirection:  Axis.horizontal,
                itemCount:        post.imageUrls.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (_, idx) => ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    post.imageUrls[idx],
                    width:  180,
                    height: 180,
                    fit:    BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      width:  180,
                      height: 180,
                      color:  AppColors.gray200,
                      child:  const Icon(Icons.broken_image, color: AppColors.gray500),
                    ),
                  ),
                ),
              ),
            ),
          ],

          // 분석 아이템 연결 정보 (ANALYSIS_SHARE인 경우)
          if (post.analysisItemId != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color:        AppColors.purple050,
                borderRadius: BorderRadius.circular(8),
                border:       Border.all(color: AppColors.purple100),
              ),
              child: Row(
                children: [
                  const Icon(Icons.analytics_outlined, size: 16, color: AppColors.primary),
                  const SizedBox(width: 8),
                  Text(
                    '연결된 분석 아이템 ID: ${post.analysisItemId}',
                    style: AppTypography.small12.copyWith(color: AppColors.primary),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _formatDate(DateTime dt) =>
      '${dt.year}.${dt.month.toString().padLeft(2, '0')}.${dt.day.toString().padLeft(2, '0')}';
}

// ── 사기 의심 투표 카드 ──
class _FraudVoteCard extends StatelessWidget {
  final BoardFraudVoteModel? voteResult;
  final bool                 hasVoted;
  final void Function(String voteType) onVote;

  const _FraudVoteCard({
    required this.voteResult,
    required this.hasVoted,
    required this.onVote,
  });

  @override
  Widget build(BuildContext context) {
    final result = voteResult;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color:        Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '사기 의심 투표',
            style: AppTypography.largeBold16.copyWith(letterSpacing: -0.5),
          ),
          const SizedBox(height: 4),
          Text(
            '1인 1회만 투표 가능합니다.',
            style: AppTypography.small12.copyWith(color: AppColors.gray500),
          ),

          if (result != null) ...[
            const SizedBox(height: 16),
            // 투표 결과 바
            _VoteBar(
              fraudRatio:    result.fraudRatio,
              notFraudRatio: result.notFraudRatio,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _VoteCountBadge(
                  label: '사기',
                  count: result.fraudCount,
                  color: AppColors.error,
                ),
                const Spacer(),
                _VoteCountBadge(
                  label: '정상',
                  count: result.notFraudCount,
                  color: AppColors.success,
                ),
              ],
            ),
            const SizedBox(height: 4),
            Center(
              child: Text(
                '총 ${result.total}명 참여',
                style: AppTypography.small12.copyWith(color: AppColors.gray500),
              ),
            ),
          ],

          const SizedBox(height: 16),

          // 투표 버튼
          if (!hasVoted)
            Row(
              children: [
                Expanded(
                  child: _VoteButton(
                    label:   '사기 의심',
                    color:   AppColors.error,
                    onTap:   () => onVote('FRAUD'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _VoteButton(
                    label:   '정상 같음',
                    color:   AppColors.success,
                    onTap:   () => onVote('NOT_FRAUD'),
                  ),
                ),
              ],
            )
          else
            Center(
              child: Text(
                '투표가 완료되었습니다.',
                style: AppTypography.small12.copyWith(color: AppColors.gray500),
              ),
            ),
        ],
      ),
    );
  }
}

class _VoteBar extends StatelessWidget {
  final double fraudRatio;
  final double notFraudRatio;
  const _VoteBar({required this.fraudRatio, required this.notFraudRatio});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: SizedBox(
        height: 12,
        child: Row(
          children: [
            if (fraudRatio > 0)
              Expanded(
                flex: (fraudRatio * 100).round(),
                child: Container(color: AppColors.error),
              ),
            if (notFraudRatio > 0)
              Expanded(
                flex: (notFraudRatio * 100).round(),
                child: Container(color: AppColors.success),
              ),
            // 투표 0건일 경우 빈 바
            if (fraudRatio == 0 && notFraudRatio == 0)
              Expanded(child: Container(color: AppColors.gray200)),
          ],
        ),
      ),
    );
  }
}

class _VoteCountBadge extends StatelessWidget {
  final String label;
  final int    count;
  final Color  color;
  const _VoteCountBadge({required this.label, required this.count, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 4),
        Text(
          '$label $count명',
          style: AppTypography.small12.copyWith(color: AppColors.gray500),
        ),
      ],
    );
  }
}

class _VoteButton extends StatelessWidget {
  final String   label;
  final Color    color;
  final VoidCallback onTap;
  const _VoteButton({required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 44,
        decoration: BoxDecoration(
          color:        color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border:       Border.all(color: color, width: 1.5),
        ),
        child: Center(
          child: Text(
            label,
            style: AppTypography.middleBold15.copyWith(color: color),
          ),
        ),
      ),
    );
  }
}

// ── 댓글 목록 섹션 ──
class _CommentsSection extends StatelessWidget {
  final List<BoardCommentModel> comments;
  final void Function(int commentId, String nickname) onReplyTap;

  const _CommentsSection({required this.comments, required this.onReplyTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color:        Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '댓글 ${comments.length}',
            style: AppTypography.largeBold16.copyWith(letterSpacing: -0.5),
          ),
          const SizedBox(height: 12),

          if (comments.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Text(
                  '첫 번째 댓글을 작성해보세요.',
                  style: AppTypography.small12.copyWith(color: AppColors.gray500),
                ),
              ),
            )
          else
            ...comments.map((c) => _CommentItem(comment: c, onReplyTap: onReplyTap)),
        ],
      ),
    );
  }
}

// ── 댓글 아이템 ──
class _CommentItem extends StatelessWidget {
  final BoardCommentModel comment;
  final void Function(int commentId, String nickname) onReplyTap;

  const _CommentItem({required this.comment, required this.onReplyTap});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(height: 1, color: AppColors.gray200),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 댓글 작성자 + 날짜
              Row(
                children: [
                  Text(
                    comment.authorNickname,
                    style: AppTypography.smallBold12,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _formatDate(comment.createdAt),
                    style: AppTypography.small10,
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => onReplyTap(comment.id, comment.authorNickname),
                    child: Text(
                      '답글',
                      style: AppTypography.small12.copyWith(color: AppColors.primary),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(comment.content, style: AppTypography.middle14),

              // 대댓글
              if (comment.replies.isNotEmpty) ...[
                const SizedBox(height: 8),
                ...comment.replies.map((r) => _ReplyItem(reply: r)),
              ],
            ],
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime dt) =>
      '${dt.year}.${dt.month.toString().padLeft(2, '0')}.${dt.day.toString().padLeft(2, '0')}';
}

// ── 대댓글 아이템 ──
class _ReplyItem extends StatelessWidget {
  final BoardReplyModel reply;
  const _ReplyItem({required this.reply});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, top: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.subdirectory_arrow_right, size: 14, color: AppColors.gray500),
          const SizedBox(width: 6),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(reply.authorNickname, style: AppTypography.smallBold12),
                    const SizedBox(width: 8),
                    Text(
                      '${reply.createdAt.year}.${reply.createdAt.month.toString().padLeft(2, '0')}.${reply.createdAt.day.toString().padLeft(2, '0')}',
                      style: AppTypography.small10,
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(reply.content, style: AppTypography.middle14),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── 댓글 입력 바 ──
class _CommentInputBar extends StatelessWidget {
  final TextEditingController controller;
  final bool         isSubmitting;
  final String?      replyTarget;   // non-null이면 대댓글 모드
  final VoidCallback onCancelReply;
  final VoidCallback onSubmit;

  const _CommentInputBar({
    required this.controller,
    required this.isSubmitting,
    required this.replyTarget,
    required this.onCancelReply,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        decoration: BoxDecoration(
          color:  Colors.white,
          boxShadow: [
            BoxShadow(
              color:      Colors.black.withOpacity(0.06),
              offset:     const Offset(0, -2),
              blurRadius: 8,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 대댓글 대상 표시 바
            if (replyTarget != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                color:   AppColors.purple050,
                child: Row(
                  children: [
                    Text(
                      '@$replyTarget 에게 답글',
                      style: AppTypography.small12.copyWith(color: AppColors.primary),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: onCancelReply,
                      child: const Icon(Icons.close, size: 16, color: AppColors.gray500),
                    ),
                  ],
                ),
              ),

            // 입력 필드
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color:        AppColors.gray100,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: TextField(
                        controller: controller,
                        maxLines:   null,
                        style:      AppTypography.middle14,
                        decoration: InputDecoration(
                          hintText:       replyTarget != null ? '답글을 작성해주세요.' : '댓글을 작성해주세요.',
                          hintStyle:      AppTypography.middle14.copyWith(color: AppColors.gray500),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          border:         InputBorder.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: isSubmitting ? null : onSubmit,
                    child: Container(
                      width:  40,
                      height: 40,
                      decoration: BoxDecoration(
                        color:       AppColors.primary,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: isSubmitting
                          ? const Padding(
                        padding: EdgeInsets.all(10),
                        child: CircularProgressIndicator(
                          color:       Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                          : const Icon(Icons.send, color: Colors.white, size: 20),
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

// ── 카테고리 배지 ──
class _CategoryBadge extends StatelessWidget {
  final BoardCategory category;
  const _CategoryBadge({required this.category});

  Color get _color {
    switch (category) {
      case BoardCategory.experience:    return AppColors.primary;
      case BoardCategory.fraudVote:     return AppColors.info;
      case BoardCategory.analysisShare: return AppColors.secondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color:        _color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        category.label,
        style: AppTypography.small10.copyWith(
          color:      _color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
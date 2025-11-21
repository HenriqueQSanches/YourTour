import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:async';
import 'package:you_tour_app/i18n/strings.dart';
import '../../database/database_helper.dart';
import '../../models/post.dart';
import '../../models/comment.dart';
import '../../services/session_manager.dart';

class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  final List<FeedPost> _posts = [];
  final DatabaseHelper _dbHelper = DatabaseHelper();
  final ImagePicker _imagePicker = ImagePicker();
  final TextEditingController _commentController = TextEditingController();
  StreamSubscription<void>? _postsSub;

  @override
  void dispose() {
    _commentController.dispose();
    _postsSub?.cancel();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _loadPostsFromDb();
    _postsSub = _dbHelper.postsStream.listen((_) {
      _loadPostsFromDb();
    });
  }

  Future<void> _loadPostsFromDb() async {
    try {
      final posts = await _dbHelper.getAllPosts();
      debugPrint('🔵 [FEED] getAllPosts returned ${posts.length} rows');
      final List<FeedPost> mapped = [];
      for (final p in posts) {
        final user = await _dbHelper.getUserById(p.userId);
        // carregar comentários e likes
        final comments = await _dbHelper.getCommentsByPost(p.postId ?? 0);
        final likesCount = await _dbHelper.getLikesCount(p.postId ?? 0);
        final currentUserId = SessionManager.currentUser?.userId ?? 0;
        final isLiked = await _dbHelper.userLiked(p.postId ?? 0, currentUserId);

        final List<PostComment> mappedComments = [];
        for (final c in comments) {
          final commentUser = await _dbHelper.getUserById(c.userId);
          mappedComments.add(PostComment(
            userName: commentUser?.userName ?? 'Usuário',
            text: c.text,
            timeAgo: c.timestamp,
          ));
        }

        mapped.add(FeedPost(
          postId: p.postId,
          userName: user?.userName ?? 'Usuário YouTour',
          location: p.location.isNotEmpty ? p.location : 'Local não especificado',
          caption: p.caption,
          date: p.timestamp,
          imagePath: p.imagePath,
          likes: likesCount,
          isLiked: isLiked,
          comments: mappedComments,
        ));
      }
      setState(() {
        _posts.clear();
        _posts.addAll(mapped);
      });
    } catch (e) {
      debugPrint('Erro ao carregar posts do DB: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3E5F5),
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/youtour-removebg-preview.png',
              height: 60,
              fit: BoxFit.contain,
            ),
          ],
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        toolbarHeight: 80,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF6A1B9A),
                Color(0xFF8E24AA),
              ],
            ),
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(20),
              bottomRight: Radius.circular(20),
            ),
          ),
        ),
      ),
      body: _posts.isEmpty ? _buildEmptyState() : _buildFeedList(),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreatePostDialog,
        backgroundColor: const Color(0xFF6A1B9A),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.photo_library,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            S.of(context).t('feed.empty_title'),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF6A1B9A),
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              S.of(context).t('feed.empty_subtitle'),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeedList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _posts.length,
      itemBuilder: (context, index) {
        return _buildPostCard(_posts[index], index);
      },
    );
  }

  Widget _buildPostCard(FeedPost post, int postIndex) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Cabeçalho do post
          ListTile(
            leading: CircleAvatar(
              backgroundColor: const Color(0xFF6A1B9A),
              child: Text(
                post.userName[0].toUpperCase(),
                style: const TextStyle(color: Colors.white),
              ),
            ),
            title: Text(
              post.userName,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFF6A1B9A),
              ),
            ),
            subtitle: Text(
              post.location,
              style: TextStyle(color: Colors.grey[600]),
            ),
          ),

          // Conteúdo da publicação
          if (post.caption.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                post.caption,
                style: const TextStyle(fontSize: 14),
              ),
            ),

          // Foto do post
          if (post.imagePath.isNotEmpty)
            Container(
              width: double.infinity,
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.file(
                  File(post.imagePath),
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return _buildImagePlaceholder();
                  },
                ),
              ),
            )
          else
            _buildImagePlaceholder(),

          // Estatísticas de likes e comentários
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                if (post.likes > 0)
                  Row(
                    children: [
                      Icon(
                        Icons.favorite,
                        color: Colors.pink[400],
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${post.likes}',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(width: 12),
                    ],
                  ),
                if (post.comments.isNotEmpty)
                  Row(
                    children: [
                      Icon(
                        Icons.comment,
                        color: Colors.grey[600],
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${post.comments.length} comentário${post.comments.length > 1 ? 's' : ''}',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                const Spacer(),
                Text(
                  post.date,
                  style: TextStyle(color: Colors.grey[500], fontSize: 12),
                ),
              ],
            ),
          ),

          // Botões de ação (Like e Comentário)
          Container(
            height: 40,
            margin: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              children: [
                Expanded(
                  child: TextButton.icon(
                    onPressed: () => _toggleLike(postIndex),
                    icon: Icon(
                      post.isLiked ? Icons.favorite : Icons.favorite_border,
                      color: post.isLiked ? Colors.pink[400] : Colors.grey[600],
                      size: 20,
                    ),
                    label: Text(
                      'Curtir',
                      style: TextStyle(
                        color:
                            post.isLiked ? Colors.pink[400] : Colors.grey[600],
                      ),
                    ),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.grey[600],
                    ),
                  ),
                ),
                Expanded(
                  child: TextButton.icon(
                    onPressed: () => _showCommentsDialog(postIndex),
                    icon: Icon(
                      Icons.comment,
                      color: Colors.grey[600],
                      size: 20,
                    ),
                    label: Text(
                      'Comentar',
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.grey[600],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Mostrar últimos comentários (se houver)
          if (post.comments.isNotEmpty) _buildRecentComments(post.comments),
        ],
      ),
    );
  }

  Widget _buildRecentComments(List<PostComment> comments) {
    final recentComments =
        comments.length > 2 ? comments.sublist(0, 2) : comments;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        border: Border(
          top: BorderSide(color: Colors.grey[300]!),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (comments.length > 2)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                'Ver todos os ${comments.length} comentários',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ...recentComments.map((comment) => _buildCommentTile(comment)),
        ],
      ),
    );
  }

  Widget _buildCommentTile(PostComment comment) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: RichText(
              text: TextSpan(
                style: const TextStyle(
                  fontSize: 13,
                  color: Colors.black87,
                ),
                children: [
                  TextSpan(
                    text: '${comment.userName} ',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextSpan(text: comment.text),
                ],
              ),
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: Icon(
              Icons.favorite_border,
              color: Colors.grey[500],
              size: 16,
            ),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      height: 200,
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF6A1B9A).withAlpha((0.1 * 255).round()),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Icon(
          Icons.photo_camera,
          size: 50,
          color: const Color(0xFF6A1B9A).withAlpha((0.5 * 255).round()),
        ),
      ),
    );
  }

  void _toggleLike(int postIndex) {
    final post = _posts[postIndex];
    final postId = post.postId ?? 0;
    final currentUserId = SessionManager.currentUser?.userId ?? 0;

    debugPrint('🔵 [FEED] toggleLike postId=$postId currentUserId=$currentUserId isLiked=${post.isLiked}');
    if (postId == 0) {
      debugPrint('🔴 [FEED] postId is 0, cannot toggle like');
      return;
    }

    if (currentUserId == 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Faça login para curtir'), backgroundColor: Colors.orange));
      return;
    }

    if (post.isLiked) {
      _dbHelper.removeLike(postId, currentUserId).then((_) => _loadPostsFromDb()).catchError((e) {
        debugPrint('🔴 [FEED] Erro ao remover like: $e');
      });
    } else {
      _dbHelper.addLike(postId, currentUserId).then((_) => _loadPostsFromDb()).catchError((e) {
        debugPrint('🔴 [FEED] Erro ao adicionar like: $e');
      });
    }
  }

  void _showCommentsDialog(int postIndex) {
    final post = _posts[postIndex];
    _commentController.clear();

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            // Cabeçalho do dialog
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFF6A1B9A),
                    Color(0xFF8E24AA),
                  ],
                ),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.comment, color: Colors.white),
                  const SizedBox(width: 8),
                  Text(
                    'Comentários (${post.comments.length})',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),

            // Lista de comentários
            Expanded(
              child: post.comments.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.comment_outlined,
                            size: 60,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Nenhum comentário ainda',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Seja o primeiro a comentar!',
                            style: TextStyle(
                              color: Colors.grey[500],
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: post.comments.length,
                      itemBuilder: (context, index) {
                        final comment = post.comments[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: const Color(0xFF6A1B9A),
                              child: Text(
                                comment.userName[0].toUpperCase(),
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                            title: Text(
                              comment.userName,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            subtitle: Text(comment.text),
                            trailing: Text(
                              comment.timeAgo,
                              style: TextStyle(
                                color: Colors.grey[500],
                                fontSize: 12,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),

            // Campo para adicionar comentário
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: Colors.grey[300]!),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _commentController,
                      decoration: InputDecoration(
                        hintText: 'Adicione um comentário...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                      ),
                      onSubmitted: (value) {
                        if (value.trim().isNotEmpty) {
                          _addComment(postIndex, value.trim());
                          _commentController.clear();
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  CircleAvatar(
                    backgroundColor: const Color(0xFF6A1B9A),
                    child: IconButton(
                      onPressed: () {
                        if (_commentController.text.trim().isNotEmpty) {
                          _addComment(
                              postIndex, _commentController.text.trim());
                          _commentController.clear();
                        }
                      },
                      icon:
                          const Icon(Icons.send, color: Colors.white, size: 20),
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

  void _addComment(int postIndex, String commentText) {
    if (commentText.isEmpty) return;
    final currentUser = SessionManager.currentUser;
    final userId = currentUser?.userId ?? 0;
    final postId = _posts[postIndex].postId ?? 0;
    final timestamp = DateTime.now().toIso8601String();

    final comment = Comment(
      postId: postId,
      userId: userId,
      text: commentText,
      timestamp: timestamp,
    );

    if (postId == 0) {
      debugPrint('🔴 [FEED] postId is 0, cannot add comment');
      return;
    }

    if (userId == 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Faça login para comentar'), backgroundColor: Colors.orange));
      return;
    }

    // Fecha o teclado antes de operações assíncronas
    if (mounted) FocusScope.of(context).unfocus();

    _dbHelper.insertComment(comment).then((id) {
      debugPrint('🔵 [FEED] Comentário inserido id=$id');
      if (!mounted) return;
      _loadPostsFromDb();
    }).catchError((e) {
      debugPrint('🔴 [FEED] Erro ao inserir comentário: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao salvar comentário: $e'), backgroundColor: Colors.red),
      );
    });
  }

  void _showCreatePostDialog() {
    String caption = '';
    String location = '';
    String selectedImagePath = '';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Título do dialog com a logo
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Color(0xFF6A1B9A),
                          Color(0xFF8E24AA),
                        ],
                      ),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(12),
                        topRight: Radius.circular(12),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          'assets/images/youtour-removebg-preview.png',
                          height: 50,
                          fit: BoxFit.contain,
                        ),
                        const SizedBox(width: 15),
                        Text(
                          S.of(context).t('feed.create_post'),
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Área da imagem
                  Container(
                    width: double.infinity,
                    constraints: const BoxConstraints(
                      maxHeight: 300,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.grey[50],
                    ),
                    child: selectedImagePath.isNotEmpty
                        ? Padding(
                            padding: const EdgeInsets.all(8),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.file(
                                File(selectedImagePath),
                                fit: BoxFit.contain,
                                errorBuilder: (context, error, stackTrace) {
                                  return _buildDialogImagePlaceholder();
                                },
                              ),
                            ),
                          )
                        : _buildDialogImagePlaceholder(),
                  ),

                  const SizedBox(height: 12),

                  // Botão para escolher imagem da galeria
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        final image = await _pickImage(ImageSource.gallery);
                        if (image != null) {
                          setDialogState(() {
                            selectedImagePath = image.path;
                          });
                        }
                      },
                      icon: const Icon(Icons.photo_library, size: 20),
                      label: const Text(
                        'Escolher da Galeria',
                        style: TextStyle(fontSize: 16),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF6A1B9A),
                        side: const BorderSide(color: Color(0xFF6A1B9A)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Campo de legenda
                  TextField(
                    onChanged: (value) => caption = value,
                    decoration: InputDecoration(
                      hintText: S.of(context).t('feed.caption_hint'),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                    ),
                    maxLines: 3,
                  ),

                  const SizedBox(height: 12),

                  // Campo de localização
                  TextField(
                    onChanged: (value) => location = value,
                    decoration: InputDecoration(
                      hintText: S.of(context).t('feed.location_hint'),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Botões de ação
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text(S.of(context).t('common.cancel')),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () {
                          if (caption.trim().isNotEmpty ||
                              selectedImagePath.isNotEmpty) {
                            _createNewPost(
                              caption: caption.trim(),
                              location: location.trim(),
                              imagePath: selectedImagePath,
                            );
                            Navigator.pop(context);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF6A1B9A),
                        ),
                        child: Text(S.of(context).t('common.post')),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDialogImagePlaceholder() {
    return Container(
      height: 150,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.photo_library,
            size: 40,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 8),
          Text(
            'Adicionar foto da galeria',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Future<XFile?> _pickImage(ImageSource source) async {
    try {
      final image = await _imagePicker.pickImage(
        source: source,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 80,
      );
      return image;
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao selecionar imagem: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return null;
    }
  }

  void _createNewPost({
    required String caption,
    required String location,
    required String imagePath,
  }) {
    final currentUser = SessionManager.currentUser;
    final int userId = currentUser?.userId ?? 0;
    final timestamp = DateTime.now().toIso8601String();

    final post = Post(
      userId: userId,
      caption: caption,
      imagePath: imagePath,
      location: location.isNotEmpty ? location : 'Local não especificado',
      timestamp: timestamp,
    );

    if (!mounted) return;
    _dbHelper.insertPost(post).then((id) {
      if (!mounted) return;
      _loadPostsFromDb();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(S.of(context).t('feed.post_created')),
          backgroundColor: const Color(0xFF6A1B9A),
        ),
      );
    }).catchError((e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao salvar publicação: $e'),
          backgroundColor: Colors.red,
        ),
      );
    });
  }
}

class FeedPost {
  final int? postId;
  final String userName;
  final String location;
  final String caption;
  final String date;
  final String imagePath;
  int likes;
  bool isLiked;
  List<PostComment> comments;

  FeedPost({
    this.postId,
    required this.userName,
    required this.location,
    required this.caption,
    required this.date,
    required this.imagePath,
    this.likes = 0,
    this.isLiked = false,
    List<PostComment>? comments,
  }) : comments = comments ?? [];
}

class PostComment {
  final String userName;
  final String text;
  final String timeAgo;

  PostComment({
    required this.userName,
    required this.text,
    required this.timeAgo,
  });
}

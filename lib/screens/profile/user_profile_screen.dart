import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../database/database_helper.dart';
import '../../models/post.dart';
import '../../models/comment.dart';
import '../../services/session_manager.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class ProfilePostItem {
  final int? postId;
  final String imagePath;
  final String caption;
  final String timestamp;
  int likes;
  bool isLiked;
  int commentsCount;

  ProfilePostItem({
    this.postId,
    required this.imagePath,
    required this.caption,
    required this.timestamp,
    this.likes = 0,
    this.isLiked = false,
    this.commentsCount = 0,
  });
}
class _UserProfileScreenState extends State<UserProfileScreen> {
  File? _profileImage;
  final List<ProfilePostItem> _userPosts = [];
  final DatabaseHelper _dbHelper = DatabaseHelper();

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _loadUserPosts();
  }

  Future<void> _loadUserPosts() async {
    final currentUser = SessionManager.currentUser;
    if (currentUser == null || currentUser.userId == null) return;
    try {
      final posts = await _dbHelper.getPostsByUser(currentUser.userId!);
      final List<ProfilePostItem> mapped = [];
      for (final p in posts) {
        final likes = await _dbHelper.getLikesCount(p.postId ?? 0);
        final isLiked = await _dbHelper.userLiked(p.postId ?? 0, currentUser.userId!);
        final comments = await _dbHelper.getCommentsByPost(p.postId ?? 0);
        mapped.add(ProfilePostItem(
          postId: p.postId,
          imagePath: p.imagePath,
          caption: p.caption,
          timestamp: p.timestamp,
          likes: likes,
          isLiked: isLiked,
          commentsCount: comments.length,
        ));
      }
      setState(() {
        _userPosts.clear();
        _userPosts.addAll(mapped);
      });
    } catch (e) {
      debugPrint('Erro ao carregar posts do usuário: $e');
    }
  }

  void _showImageSourceActionSheet() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Escolher da galeria'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // Like handling for profile posts is implemented inline in the post card.
  // Removed placeholder `_toggleLike` to avoid analyzer warnings.

  

  void _showFullImage(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      builder: (context) => FullScreenImageDialog(imageUrl: imageUrl),
    );
  }

  Widget _buildPostCardFromPost(ProfilePostItem post) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Imagem do post - Agora clicável
          GestureDetector(
            onTap: () => _showFullImage(context, post.imagePath.isNotEmpty ? post.imagePath : ''),
            child: Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
              child: post.imagePath.isNotEmpty
                ? Image.file(File(post.imagePath), fit: BoxFit.cover, errorBuilder: (c, e, s) {
                      return Container(color: Colors.grey[200], child: const Icon(Icons.photo, size: 60));
                    })
                  : Container(color: Colors.grey[200], child: const Icon(Icons.photo, size: 60)),
            ),
          ),
          // Conteúdo do post
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  post.caption,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      post.timestamp,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                    Row(
                      children: [
                        // Botão de curtir
                            IconButton(
                              onPressed: () async {
                                final currentUser = SessionManager.currentUser;
                                if (currentUser == null || currentUser.userId == null) {
                                  if (!mounted) return;
                                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Faça login para curtir'), backgroundColor: Colors.orange));
                                  return;
                                }
                                final postId = post.postId ?? 0;
                                if (postId == 0) return;
                                if (post.isLiked) {
                                  await _dbHelper.removeLike(postId, currentUser.userId!);
                                } else {
                                  await _dbHelper.addLike(postId, currentUser.userId!);
                                }
                                if (!mounted) return;
                                await _loadUserPosts();
                              },
                              icon: Icon(
                                post.isLiked ? Icons.favorite : Icons.favorite_border,
                                color: post.isLiked ? Colors.red : Colors.grey,
                                size: 20,
                              ),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                            Text(
                              '${post.likes}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(width: 16),
                        // Botão de comentários
                        IconButton(
                          onPressed: () {
                            showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              builder: (context) => ProfileCommentsBottomSheet(postId: post.postId ?? 0),
                            );
                          },
                          icon: const Icon(
                            Icons.comment,
                            color: Colors.grey,
                            size: 20,
                          ),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                        Text(
                          '${post.commentsCount}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3E5F5),
      body: CustomScrollView(
        slivers: [
          // AppBar personalizada com imagem de fundo
          SliverAppBar(
            expandedHeight: 280, // Altura total da imagem de fundo
            stretch: true,
            flexibleSpace: FlexibleSpaceBar(
              stretchModes: const [
                StretchMode.zoomBackground,
                StretchMode.blurBackground,
              ],
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // Imagem de fundo cobrindo toda a área
                  Image.asset(
                    'assets/images/Aesthetic pictures - Aesthetic wallpapers - AI pictures 179.jpg',
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: const Color(0xFF6A1B9A),
                        child: const Center(
                          child: Icon(
                            Icons.photo,
                            color: Colors.white,
                            size: 50,
                          ),
                        ),
                      );
                    },
                  ),
                  // Gradiente escuro para melhor legibilidade
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          Colors.black.withAlpha((0.6 * 255).round()),
                          Colors.transparent,
                          Colors.black.withAlpha((0.3 * 255).round()),
                        ],
                      ),
                    ),
                  ),
                  // Conteúdo sobreposto
                  Padding(
                    padding: const EdgeInsets.only(bottom: 40.0),
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Foto de perfil
                          Stack(
                            children: [
                              Container(
                                width: 120,
                                height: 120,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 4,
                                  ),
                                  color: Colors.white,
                                ),
                                child: ClipOval(
                                  child: _profileImage != null
                                      ? Image.file(
                                          _profileImage!,
                                          fit: BoxFit.cover,
                                        )
                                      : Container(
                                          color: Colors.white,
                                          child: const Icon(
                                            Icons.person,
                                            size: 60,
                                            color: Color(0xFF6A1B9A),
                                          ),
                                        ),
                                ),
                              ),
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: GestureDetector(
                                  onTap: _showImageSourceActionSheet,
                                  child: Container(
                                    width: 36,
                                    height: 36,
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.white,
                                    ),
                                    child: const Icon(
                                      Icons.camera_alt,
                                      size: 18,
                                      color: Color(0xFF6A1B9A),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          // Nome do usuário
                          const Text(
                            'João Silva',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          // Email do usuário
                          const Text(
                            'joao.silva@email.com',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            backgroundColor: Colors.transparent,
            leading: Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.black.withAlpha((0.5 * 255).round()),
                ),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
            // Título removido
            title: null,
            centerTitle: false,
            pinned: true,
            floating: false,
            snap: false,
            elevation: 0,
          ),
          // Estatísticas
          SliverToBoxAdapter(
            child: Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                    _buildStatItem('Posts', _userPosts.length.toString()),
                    _buildStatItem('Seguidores', '0'),
                    _buildStatItem('Seguindo', '0'),
                ],
              ),
            ),
          ),
          // Seção de posts
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Meus Posts',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
              ),
            ),
          ),
          // Lista de posts
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                return _buildPostCardFromPost(_userPosts[index]);
              },
              childCount: _userPosts.length,
            ),
          ),
          const SliverToBoxAdapter(
            child: SizedBox(height: 20),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showCreatePostDialog,
        backgroundColor: const Color(0xFF6A1B9A),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Future<String?> _pickPostImage() async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 80,
      );
      return picked?.path;
    } catch (e) {
      if (!mounted) return null;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao selecionar imagem: $e'), backgroundColor: Colors.red),
      );
      return null;
    }
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
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Color(0xFF6A1B9A), Color(0xFF8E24AA)],
                      ),
                      borderRadius: BorderRadius.only(topLeft: Radius.circular(12), topRight: Radius.circular(12)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset('assets/images/youtour-removebg-preview.png', height: 40, fit: BoxFit.contain),
                        const SizedBox(width: 8),
                        const Text('Criar Publicação', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // preview da imagem
                  Container(
                    width: double.infinity,
                    constraints: const BoxConstraints(maxHeight: 250),
                    decoration: BoxDecoration(border: Border.all(color: Colors.grey[300]!), borderRadius: BorderRadius.circular(8), color: Colors.grey[50]),
                    child: selectedImagePath.isNotEmpty
                        ? Padding(
                            padding: const EdgeInsets.all(8),
                            child: ClipRRect(borderRadius: BorderRadius.circular(8), child: Image.file(File(selectedImagePath), fit: BoxFit.contain)),
                          )
                        : Container(height: 140, child: const Center(child: Icon(Icons.photo_library, size: 36, color: Colors.grey))),
                  ),
                  const SizedBox(height: 12),

                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        final path = await _pickPostImage();
                        if (path != null) {
                          setDialogState(() => selectedImagePath = path);
                        }
                      },
                      icon: const Icon(Icons.photo_library),
                      label: const Text('Escolher da Galeria'),
                    ),
                  ),

                  const SizedBox(height: 8),
                  TextField(
                    onChanged: (v) => caption = v,
                    decoration: const InputDecoration(hintText: 'Legenda', border: OutlineInputBorder()),
                    maxLines: 3,
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    onChanged: (v) => location = v,
                    decoration: const InputDecoration(hintText: 'Localização', border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () async {
                          if (caption.trim().isEmpty && selectedImagePath.isEmpty) return;
                          final currentUser = SessionManager.currentUser;
                          final userId = currentUser?.userId ?? 0;
                          final timestamp = DateTime.now().toIso8601String();
                          final post = Post(userId: userId, caption: caption.trim(), imagePath: selectedImagePath, location: location.trim(), timestamp: timestamp);
                          try {
                            await _dbHelper.insertPost(post);
                            if (!mounted) return;
                            await _loadUserPosts();
                            if (!mounted) return;
                            Navigator.pop(context);
                            if (!mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Publicação criada!'), backgroundColor: Color(0xFF6A1B9A)));
                          } catch (e) {
                            if (!mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro ao salvar publicação: $e'), backgroundColor: Colors.red));
                          }
                        },
                        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF6A1B9A)),
                        child: const Text('Publicar'),
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

  Widget _buildStatItem(String title, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF6A1B9A),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          title,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }
}

// Bottom Sheet para exibir comentários e permitir salvar no DB
class ProfileCommentsBottomSheet extends StatefulWidget {
  final int postId;

  const ProfileCommentsBottomSheet({super.key, required this.postId});

  @override
  State<ProfileCommentsBottomSheet> createState() => _ProfileCommentsBottomSheetState();
}

class _ProfileCommentsBottomSheetState extends State<ProfileCommentsBottomSheet> {
  final TextEditingController _commentController = TextEditingController();
  final List<Comment> _comments = [];
  final DatabaseHelper _dbHelper = DatabaseHelper();

  @override
  void initState() {
    super.initState();
    _loadComments();
  }

  Future<void> _loadComments() async {
    try {
      final comments = await _dbHelper.getCommentsByPost(widget.postId);
      setState(() {
        _comments.clear();
        _comments.addAll(comments);
      });
    } catch (e) {
      debugPrint('Erro ao carregar comentários do post ${widget.postId}: $e');
    }
  }

  void _addComment() async {
    final text = _commentController.text.trim();
    if (text.isEmpty) return;
    final currentUser = SessionManager.currentUser;
    if (currentUser == null || currentUser.userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Faça login para comentar'), backgroundColor: Colors.orange));
      return;
    }

    final comment = Comment(postId: widget.postId, userId: currentUser.userId!, text: text, timestamp: DateTime.now().toIso8601String());
    try {
      await _dbHelper.insertComment(comment);
      _commentController.clear();
      await _loadComments();
    } catch (e) {
      debugPrint('Erro ao inserir comentário: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Erro ao salvar comentário'), backgroundColor: Colors.red));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Comentários (${_comments.length})', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: _comments.isEmpty
                ? const Center(child: Text('Nenhum comentário ainda', style: TextStyle(color: Colors.grey)))
                : ListView.builder(
                    itemCount: _comments.length,
                    itemBuilder: (context, index) {
                      final c = _comments[index];
                      return FutureBuilder(
                        future: _dbHelper.getUserById(c.userId),
                        builder: (context, snap) {
                          final userName = snap.data?.userName ?? 'Usuário';
                          return Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(8)),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(userName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                    Text(c.timestamp, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(c.text),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  ),
          ),
          Container(
            margin: const EdgeInsets.only(top: 16, bottom: 16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(controller: _commentController, decoration: InputDecoration(hintText: 'Adicione um comentário...', border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)))),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  backgroundColor: const Color(0xFF6A1B9A),
                  child: IconButton(onPressed: _addComment, icon: const Icon(Icons.send, color: Colors.white, size: 20)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }
}

// Dialog para imagem em tela cheia
class FullScreenImageDialog extends StatelessWidget {
  final String imageUrl;

  const FullScreenImageDialog({super.key, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.black,
      insetPadding: EdgeInsets.zero,
      child: Stack(
        children: [
          // Imagem em tela cheia
          Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            child: InteractiveViewer(
              panEnabled: true,
              minScale: 0.5,
              maxScale: 3.0,
              child: Image.asset(
                imageUrl,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.photo, color: Colors.white, size: 50),
                        SizedBox(height: 8),
                        Text(
                          'Imagem não encontrada',
                          style: TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
          // Botão de fechar
          Positioned(
            top: 40,
            right: 20,
            child: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.close, color: Colors.white, size: 30),
            ),
          ),
        ],
      ),
    );
  }
}

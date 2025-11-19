import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  File? _profileImage;
  final List<Map<String, dynamic>> _userPosts = [
    {
      'id': 1,
      'image': 'assets/images/post1.jpg',
      'description': 'Um dia incrível visitando este lugar maravilhoso!',
      'date': '2024-01-15',
      'likes': 24,
      'isLiked': false,
      'comments': [
        {'user': 'Maria', 'comment': 'Que lugar lindo!', 'date': '2024-01-15'},
        {
          'user': 'Pedro',
          'comment': 'Preciso visitar também!',
          'date': '2024-01-16'
        },
      ],
    },
    {
      'id': 2,
      'image': 'assets/images/post2.jpg',
      'description': 'Paisagem deslumbrante durante o pôr do sol.',
      'date': '2024-01-10',
      'likes': 42,
      'isLiked': true,
      'comments': [
        {
          'user': 'Ana',
          'comment': 'As cores estão incríveis!',
          'date': '2024-01-10'
        },
        {
          'user': 'Carlos',
          'comment': 'Foto espetacular!',
          'date': '2024-01-11'
        },
        {
          'user': 'Julia',
          'comment': 'Onde foi tirada essa foto?',
          'date': '2024-01-12'
        },
      ],
    },
    {
      'id': 3,
      'image': 'assets/images/post3.jpg',
      'description': 'Explorando novos horizontes!',
      'date': '2024-01-05',
      'likes': 18,
      'isLiked': false,
      'comments': [
        {
          'user': 'Lucas',
          'comment': 'Aventura incrível!',
          'date': '2024-01-05'
        },
      ],
    },
  ];

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
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

  void _toggleLike(int postId) {
    setState(() {
      final post = _userPosts.firstWhere((post) => post['id'] == postId);
      if (post['isLiked']) {
        post['likes']--;
        post['isLiked'] = false;
      } else {
        post['likes']++;
        post['isLiked'] = true;
      }
    });
  }

  void _showComments(BuildContext context, Map<String, dynamic> post) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => CommentsBottomSheet(post: post),
    );
  }

  void _showFullImage(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      builder: (context) => FullScreenImageDialog(imageUrl: imageUrl),
    );
  }

  Widget _buildPostCard(Map<String, dynamic> post) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Imagem do post - Agora clicável
          GestureDetector(
            onTap: () => _showFullImage(context, post['image']),
            child: Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
                image: DecorationImage(
                  image: AssetImage(post['image']),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          // Conteúdo do post
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  post['description'],
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
                      post['date'],
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                    Row(
                      children: [
                        // Botão de curtir
                        IconButton(
                          onPressed: () => _toggleLike(post['id']),
                          icon: Icon(
                            post['isLiked']
                                ? Icons.favorite
                                : Icons.favorite_border,
                            color: post['isLiked'] ? Colors.red : Colors.grey,
                            size: 20,
                          ),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                        Text(
                          '${post['likes']}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(width: 16),
                        // Botão de comentários
                        IconButton(
                          onPressed: () => _showComments(context, post),
                          icon: const Icon(
                            Icons.comment,
                            color: Colors.grey,
                            size: 20,
                          ),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                        Text(
                          '${post['comments'].length}',
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
                          Colors.black.withOpacity(0.6),
                          Colors.transparent,
                          Colors.black.withOpacity(0.3),
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
                  color: Colors.black.withOpacity(0.5),
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
                  _buildStatItem('Seguidores', '128'),
                  _buildStatItem('Seguindo', '86'),
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
                return _buildPostCard(_userPosts[index]);
              },
              childCount: _userPosts.length,
            ),
          ),
          const SliverToBoxAdapter(
            child: SizedBox(height: 20),
          ),
        ],
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

// Bottom Sheet para exibir comentários
class CommentsBottomSheet extends StatefulWidget {
  final Map<String, dynamic> post;

  const CommentsBottomSheet({super.key, required this.post});

  @override
  State<CommentsBottomSheet> createState() => _CommentsBottomSheetState();
}

class _CommentsBottomSheetState extends State<CommentsBottomSheet> {
  final TextEditingController _commentController = TextEditingController();
  final List<Map<String, String>> _comments = [];

  @override
  void initState() {
    super.initState();
    // Inicializa com os comentários existentes do post
    _comments.addAll(widget.post['comments'].cast<Map<String, String>>());
  }

  void _addComment() {
    if (_commentController.text.trim().isNotEmpty) {
      setState(() {
        _comments.insert(0, {
          'user': 'Você',
          'comment': _commentController.text.trim(),
          'date': 'Agora',
        });
      });
      _commentController.clear();
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
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Comentários (${_comments.length})',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Lista de comentários
          Expanded(
            child: _comments.isEmpty
                ? const Center(
                    child: Text(
                      'Nenhum comentário ainda',
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    itemCount: _comments.length,
                    itemBuilder: (context, index) {
                      final comment = _comments[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  comment['user']!,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                                Text(
                                  comment['date']!,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(comment['comment']!),
                          ],
                        ),
                      );
                    },
                  ),
          ),
          // Campo para adicionar comentário
          Container(
            margin: const EdgeInsets.only(top: 16, bottom: 16),
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
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 16),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  backgroundColor: const Color(0xFF6A1B9A),
                  child: IconButton(
                    onPressed: _addComment,
                    icon: const Icon(Icons.send, color: Colors.white, size: 20),
                  ),
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

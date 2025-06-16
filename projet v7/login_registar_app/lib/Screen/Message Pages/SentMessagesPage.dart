import 'package:flutter/material.dart';
import 'package:login_registar_app/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:login_registar_app/config.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import '../UserProfileViewPage.dart';
class SentMessagesPage extends StatefulWidget {
  const SentMessagesPage({super.key});

  @override
  State<SentMessagesPage> createState() => _SentMessagesPageState();
}

class _SentMessagesPageState extends State<SentMessagesPage> {
  List<Map<String, dynamic>> _conversations = [];
  bool _isLoading = true;
  bool _hasError = false;
  int? _userId;
  String _searchQuery = '';

  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _fetchConversations();
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _scrollListener() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      // Implement pagination if needed
    }
  }

  Future<void> _fetchConversations() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      _userId = prefs.getInt('user_id');

      if (token == null || _userId == null) {
        throw Exception('Authentication required');
      }

      final response = await http.get(
        Uri.parse('${Config.baseUrl}/conversations'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final conversations = data['conversations'] as List;

        setState(() {
          _conversations = conversations.map((c) {
            final latestMessage = c['latest_message'] ?? {};
            return {
              'id': c['conversation_id'],
              'recipient': c['other_name'] ?? 'Unknown',
              'preview': latestMessage['content'] ?? '',
              'date': latestMessage['created_at'] ?? '',
              'employer_id': c['other_id'],
              'isMine': latestMessage['sender_id'] == _userId,
              'avatar': _generateAvatarUrl(c['other_name']),
            };
          }).toList();
          _isLoading = false;
        });
      } else {
        throw Exception('Failed to load conversations');
      }
    } catch (e) {
      setState(() {
        _hasError = true;
        _isLoading = false;
      });
    }
  }

  String _generateAvatarUrl(String name) {
    // You can replace this with your actual avatar URL generation logic
    return 'https://ui-avatars.com/api/?name=${name.split(' ').join('+')}&background=${primaryColor.value.toRadixString(16).substring(2)}&color=ffffff';
  }

  List<Map<String, dynamic>> get _filteredConversations {
    if (_searchQuery.isEmpty) return _conversations;
    return _conversations.where((conv) =>
        conv['recipient'].toLowerCase().contains(_searchQuery.toLowerCase()) ||
        conv['preview'].toLowerCase().contains(_searchQuery.toLowerCase())).toList();
  }

  String _formatDate(String dateString) {
    return dateString;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Messages envoyés'),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, size: 24),
            onPressed: _fetchConversations,
            tooltip: 'Actualiser',
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          Expanded(
            child: _buildConversationList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Rechercher des conversations...',
          prefixIcon: const Icon(Icons.search, color: Colors.grey),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.close, size: 20),
                  onPressed: () {
                    _searchController.clear();
                    setState(() {
                      _searchQuery = '';
                    });
                  },
                )
              : null,
        ),
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
          });
        },
      ),
    );
  }

  Widget _buildConversationList() {
if (_isLoading) {
  return Center(
    child: CircularProgressIndicator(
      strokeWidth: 2,
      color: primaryColor, // This works now
    ),
  );
}


    if (_hasError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            const Text(
              'Erreur de chargement',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Impossible de charger les conversations',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _fetchConversations,
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: const Text(
                'Réessayer',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      );
    }

    if (_filteredConversations.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.forum_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              _searchQuery.isEmpty
                  ? 'Aucune conversation'
                  : 'Aucun résultat trouvé',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _searchQuery.isEmpty
                  ? 'Vous n\'avez aucune conversation'
                  : 'Aucune conversation ne correspond à votre recherche',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _fetchConversations,
      color: primaryColor,
      child: ListView.separated(
        controller: _scrollController,
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        itemCount: _filteredConversations.length,
        separatorBuilder: (context, index) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final conversation = _filteredConversations[index];
          return _buildConversationItem(conversation);
        },
      ),
    );
  }

Widget _buildConversationItem(Map<String, dynamic> conversation) {
  return Material(
    color: Colors.transparent,
    child: InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () {
        Navigator.pushNamed(
          context,
          '/message',
          arguments: {
            'conversationId': conversation['id'],
            'employerId': conversation['employer_id'],
            'employerName': conversation['recipient'],
            'jobTitle': '',
          },
        ).then((_) => _fetchConversations());
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Avatar with tap
            GestureDetector(
              onTap: () => _navigateToUserProfile(
                conversation['employer_id'],
                conversation['recipient'],
              ),
              child: _buildAvatar(conversation['avatar']),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () => _navigateToUserProfile(
                          conversation['employer_id'],
                          conversation['recipient'],
                        ),
                        child: Text(
                          conversation['recipient'],
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        _formatDate(conversation['date']),
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      if (conversation['isMine'])
                        Text(
                          'Vous: ',
                          style: TextStyle(
                            color: primaryColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      Expanded(
                        child: Text(
                          conversation['preview'],
                          style: TextStyle(
                            color: Colors.grey[700],
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}


  Widget _buildAvatar(String avatarUrl) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: primaryColor.withOpacity(0.1),
      ),
      child: ClipOval(
        child: Image.network(
          avatarUrl,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => Icon(
            Icons.person_outline,
            color: primaryColor,
            size: 24,
          ),
        ),
      ),
    );
  }
  void _navigateToUserProfile(int userId, String userName) {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => UserProfileViewPage(
        userId: userId,
        userName: userName,
      ),
    ),
  );
}

}
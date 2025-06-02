import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:login_registar_app/config.dart';
import 'UserProfileViewPage.dart';

class JobRequestsPage extends StatefulWidget {
  final int jobId;
  final String jobTitle;

  const JobRequestsPage({Key? key, required this.jobId, required this.jobTitle}) : super(key: key);

  @override
  _JobRequestsPageState createState() => _JobRequestsPageState();
}

class _JobRequestsPageState extends State<JobRequestsPage> {
  List<dynamic> _requests = [];
  List<dynamic> _filteredRequests = [];
  bool _isLoading = true;
  String _currentFilter = 'all';

  @override
  void initState() {
    super.initState();
    _fetchJobRequests();
  }

  void _applyFilter(String filter) {
    setState(() {
      _currentFilter = filter;
      _filterRequests();
    });
  }

  void _filterRequests() {
    if (_currentFilter == 'all') {
      _filteredRequests = List.from(_requests);
    } else {
      _filteredRequests = _requests.where((request) {
        final req = request['req'] as Map<String, dynamic>? ?? {};
        final status = req['status'] as String? ?? 'pending';
        return status == _currentFilter;
      }).toList();
    }
  }

  Future<void> _fetchJobRequests() async {
    setState(() => _isLoading = true);
    
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    try {
      final response = await http.get(
        Uri.parse('${Config.baseUrl}/employeur/${widget.jobId}/requests'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        setState(() {
          _requests = responseData['data'] ?? [];
          _filterRequests();
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Erreur de chargement des demandes")),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur de connexion: ${e.toString()}")),
      );
    }
  }

  Future<void> _showConfirmationDialog(int? requestId, String status) async {
    if (requestId == null) return;

    final actionText = status == 'accepted' ? 'Accepter' : 'Refuser';
    final actionColor = status == 'accepted' ? Colors.blue : Colors.red;

    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Confirmer l'action"),
          content: Text("Voulez-vous vraiment $actionText cette demande?"),
          actions: <Widget>[
            TextButton(
              child: Text('Annuler', style: TextStyle(color: Colors.grey[600])),
              onPressed: () => Navigator.of(context).pop(false),
            ),
            TextButton(
              child: Text(actionText, style: TextStyle(color: actionColor)),
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      await _respondToRequest(requestId, status);
    }
  }

  Future<void> _respondToRequest(int? requestId, String status) async {
    if (requestId == null) return;

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    try {
      final response = await http.post(
        Uri.parse('${Config.baseUrl}/employeur/requests/$requestId/respond'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: json.encode({'status': status}),
      );

      if (response.statusCode == 200) {
        // First refresh the data
        await _fetchJobRequests();
        
        // Then determine if we need to change the filter
        if (_currentFilter == 'accepted' && status == 'rejected') {
          _applyFilter('pending');
        } else if (_currentFilter == 'pending' && status == 'accepted') {
          _applyFilter('accepted');
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Demande ${status == 'accepted' ? 'acceptée' : 'rejetée'} avec succès")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erreur lors de la mise à jour de la demande")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur de connexion: ${e.toString()}")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Candidatures pour ${widget.jobTitle}',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 18,
            color: Colors.grey[800],
          ),
        ),
        centerTitle: false,
        elevation: 0,
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.grey[600]),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, color: Colors.grey[200]),
        ),
      ),
      body: Container(
        color: Colors.grey[50],
        child: Column(
          children: [
            // Filter buttons row
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildFilterButton('Tous', 'all'),
                    const SizedBox(width: 8),
                    _buildFilterButton('En attente', 'pending'),
                    const SizedBox(width: 8),
                    _buildFilterButton('Acceptées', 'accepted'),
                    const SizedBox(width: 8),
                    _buildFilterButton('Rejetées', 'rejected'),
                  ],
                ),
              ),
            ),
            // Request list
            Expanded(
              child: _isLoading
                  ? Center(
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.blue[600]!),
                      ),
                    )
                  : _filteredRequests.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.assignment_outlined, 
                                  size: 48, color: Colors.grey[400]),
                              const SizedBox(height: 16),
                              Text(
                                _currentFilter == 'all'
                                    ? 'Aucune candidature reçue'
                                    : 'Aucune candidature ${_getFilterLabel(_currentFilter)}',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                          itemCount: _filteredRequests.length,
                          separatorBuilder: (context, index) => 
                              const SizedBox(height: 16),
                          itemBuilder: (context, index) {
                            final request = _filteredRequests[index];
                            return _buildRequestCard(request);
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterButton(String label, String filter) {
    final isActive = _currentFilter == filter;
    return OutlinedButton(
      onPressed: () => _applyFilter(filter),
      style: OutlinedButton.styleFrom(
        backgroundColor: isActive ? Colors.blue[50] : Colors.white,
        side: BorderSide(
          color: isActive ? Colors.blue : Colors.grey[300]!,
          width: isActive ? 1.5 : 1,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isActive ? Colors.blue : Colors.grey[700],
          fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
          fontSize: 13,
        ),
      ),
    );
  }

  String _getFilterLabel(String filter) {
    switch (filter) {
      case 'pending': return 'en attente';
      case 'accepted': return 'acceptée';
      case 'rejected': return 'rejetée';
      default: return '';
    }
  }

  Widget _buildRequestCard(Map<String, dynamic> request) {
    final req = request['req'] as Map<String, dynamic>? ?? {};
    final requestId = req['id'] as int?;
    final userId = request['user_id'] as int?;
    final userName = request['user_name'] as String? ?? 'Utilisateur';
    final message = request['message'] as String?;
    final createdAt = request['created_at'] as String?;
    final status = req['status'] as String? ?? 'pending';

    Color statusColor = Colors.grey;
    if (status == 'accepted') {
      statusColor = Colors.green;
    } else if (status == 'rejected') {
      statusColor = Colors.red;
    }

    final bool showAcceptButton = status != 'accepted';
    final bool showRejectButton = status != 'rejected';

    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: () {
        if (userId != null) {
          Navigator.pushNamed(
            context,
            '/message',
            arguments: {
              'jobId': widget.jobId,
              'employerId': userId,
              'employerName': userName,
              'jobTitle': widget.jobTitle,
            },
          );
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.blue[50],
                    ),
                    child: Icon(Icons.person_outline, 
                        color: Colors.blue[600], size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  if (userId != null) {
                                    _navigateToUserProfile(userId, userName);
                                  }
                                },
                                child: Text(
                                  userName,
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.blue[600],
                                  ),
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: statusColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: statusColor.withOpacity(0.3),
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                _getStatusLabel(status),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: statusColor,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (createdAt != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 2),
                            child: Text(
                              'Postulé le $createdAt',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[500],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  Icon(Icons.chevron_right, 
                      color: Colors.grey[400], size: 20),
                ],
              ),
            ),
            
            if (message != null && message.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Text(
                  message,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[700],
                  ),
                ),
              ),
            
            const Divider(height: 1, thickness: 1, color: Colors.white),
            
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  if (showRejectButton) Expanded(
                    child: TextButton(
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                        backgroundColor: Colors.red[50],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.close, 
                              size: 18, color: Colors.red[600]),
                          const SizedBox(width: 6),
                          Text(
                            'REFUSER',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Colors.red[600],
                            ),
                          ),
                        ],
                      ),
                      onPressed: () => _showConfirmationDialog(requestId, 'rejected'),
                    ),
                  ),
                  if (showRejectButton && showAcceptButton) const SizedBox(width: 12),
                  if (showAcceptButton) Expanded(
                    child: TextButton(
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                        backgroundColor: Colors.blue[600],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.check, 
                              size: 18, color: Colors.white),
                          const SizedBox(width: 6),
                          Text(
                            'ACCEPTER',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      onPressed: () => _showConfirmationDialog(requestId, 'accepted'),
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

  String _getStatusLabel(String? status) {
    switch (status) {
      case 'pending': return 'En attente';
      case 'accepted': return 'Acceptée';
      case 'rejected': return 'Rejetée';
      default: return 'Inconnu';
    }
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
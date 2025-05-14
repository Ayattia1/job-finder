import 'package:flutter/material.dart';
import 'package:login_registar_app/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../screen/profile_page.dart';
import '../screen/AddJobPage.dart';
import '../screen/UserJobOffersPage.dart';
import '../Screen/FavoriteJobsPage.dart';
class CustomDrawer extends StatefulWidget {
  final String? userName;
  final String? userEmail;
  final Map<String, dynamic>? userData;
  final VoidCallback onLogout;

  const CustomDrawer({
    super.key,
    required this.userName,
    required this.userEmail,
    required this.userData,
    required this.onLogout,
  });

  @override
  State<CustomDrawer> createState() => _CustomDrawerState();
}

class _CustomDrawerState extends State<CustomDrawer> {
  bool _showJobOfferOptions = false;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        color: Colors.grey[50],
        child: Column(
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.05),
                border: Border(
                  bottom: BorderSide(color: Colors.grey.shade300, width: 1),
                ),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundImage: widget.userData != null
                        ? NetworkImage(widget.userData!['avatarUrl'])
                        : const AssetImage('assets/images/default_avatar.png')
                            as ImageProvider,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.userName ?? 'Utilisateur',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: primaryColor,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.userEmail ?? 'email@example.com',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                children: [
                  _buildDrawerButton(
                      Icons.home_outlined, 'Accueil', primaryColor, () {}),
                  _buildDrawerButton(
                      Icons.person_outline, 'Profil', primaryColor, () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (_) => ProfilePage()));
                  }),
                  _buildDrawerButton(
                    _showJobOfferOptions
                        ? Icons.expand_less
                        : Icons.expand_more,
                    'Offre d\'emploi',
                    primaryColor,
                    () {
                      setState(() {
                        _showJobOfferOptions = !_showJobOfferOptions;
                      });
                    },
                  ),
                  AnimatedCrossFade(
                    firstChild: const SizedBox.shrink(),
secondChild: Padding(
  padding: const EdgeInsets.only(left: 24),
  child: Column(
    children: [
      _buildDrawerButton(
        Icons.list_alt_outlined,
        'Votre offre d\'emploi',
        primaryColor,
        () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const UserJobOffersPage()),
          );
        },
      ),
      _buildDrawerButton(
        Icons.add_circle_outline,
        'Ajouter une offre d\'emploi',
        primaryColor,
        () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => AddJobPage()),
          );
        },
      ),
      _buildDrawerButton(
        Icons.favorite_border,
        'Offres favorites',
        primaryColor,
        () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const FavoriteJobsPage()),
          );
        },
      ),
    ],
  ),
),

                    crossFadeState: _showJobOfferOptions
                        ? CrossFadeState.showSecond
                        : CrossFadeState.showFirst,
                    duration: const Duration(milliseconds: 250),
                  ),
                ],
              ),
            ),
            const Divider(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: ElevatedButton.icon(
                onPressed: widget.onLogout,
                icon: const Icon(Icons.logout, color: Colors.white),
                label: const Text(
                  'Se déconnecter',
                  style: TextStyle(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  minimumSize: const Size.fromHeight(48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerButton(
    IconData icon,
    String title,
    Color color,
    VoidCallback onTap,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  blurRadius: 5,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              children: [
                Icon(icon, color: color, size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: color,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

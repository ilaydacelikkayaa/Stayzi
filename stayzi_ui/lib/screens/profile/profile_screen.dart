import 'package:flutter/material.dart';

import '../../models/user_model.dart';
import '../../services/api_constants.dart';
import '../../services/api_service.dart';
import '../../services/storage_service.dart';
import 'notifications_screen.dart';
import 'personal_info_screen.dart';
import 'profile_detail_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late Future<User> _userFuture;

  @override
  void initState() {
    super.initState();
    _userFuture = ApiService().getCurrentUser();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: FutureBuilder<User>(
          future: _userFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Hata: \\${snapshot.error}'));
            } else if (snapshot.hasData) {
              final user = snapshot.data!;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Profil',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.notifications_none),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const NotificationsScreen(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ProfileDetailScreen(),
                        ),
                      );
                    },
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 4,
                      color: const Color.fromARGB(255, 255, 255, 255),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 12.0,
                        ),
                        child: Row(
                          children: [
                            user.profileImage != null &&
                                    user.profileImage!.isNotEmpty
                                ? CircleAvatar(
                                  radius: 28,
                                  backgroundImage: NetworkImage(
                                    ApiConstants.baseUrl + user.profileImage!,
                                  ),
                                )
                                : CircleAvatar(
                                  radius: 28,
                                  backgroundColor: Colors.black,
                                  child: Text(
                                    user.name.isNotEmpty ? user.name[0] : '?',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${user.name} ${user.surname}',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  const Text(
                                    'Profil Göster',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.black54,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(
                              Icons.arrow_forward_ios,
                              size: 16,
                              color: Colors.black54,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const PersonalInfoScreen(),
                        ),
                      );
                    },
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 4,
                      color: const Color.fromARGB(255, 255, 255, 255),
                      child: ListTile(
                        leading: const Icon(
                          Icons.person_outline,
                          color: Color.fromARGB(255, 0, 0, 0),
                        ),
                        title: const Text('Kişisel Bilgiler'),
                        textColor: Color.fromARGB(255, 0, 0, 0),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  GestureDetector(
                    onTap: () {
                      showDialog(
                        context: context,
                        builder:
                            (context) => AlertDialog(
                              title: const Text("Çıkış Yap"),
                              content: const Text(
                                "Çıkış yapmak istediğinize emin misiniz?",
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text("İptal"),
                                ),
                                TextButton(
                                  onPressed: () async {
                                    await StorageService().logout();
                                    if (context.mounted) {
                                      Navigator.pushReplacementNamed(
                                        context,
                                        '/onboard',
                                      );
                                    }
                                  },
                                  child: const Text("Evet"),
                                ),
                              ],
                            ),
                      );
                    },
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 4,
                      color: Colors.white,
                      child: const ListTile(
                        leading: Icon(Icons.logout, color: Colors.red),
                        title: Text('Çıkış Yap'),
                        textColor: Colors.red,
                        trailing: Icon(
                          Icons.arrow_forward_ios,
                          size: 16,
                          color: Colors.red,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  GestureDetector(
                    onTap: () {
                      showDialog(
                        context: context,
                        builder:
                            (context) => AlertDialog(
                              title: const Text("Hesabı Devre Dışı Bırak"),
                              content: const Text(
                                "Hesabınızı devre dışı bırakmak istediğinize emin misiniz? Bu işlem geri alınamaz.",
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text("Vazgeç"),
                                ),
                                TextButton(
                                  onPressed: () async {
                                    try {
                                      await ApiService().deactivateAccount();
                                      await StorageService().logout();
                                      if (context.mounted) {
                                        Navigator.pushReplacementNamed(
                                          context,
                                          '/onboard',
                                        );
                                      }
                                    } catch (e) {
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              'Hesap devre dışı bırakılamadı: $e',
                                            ),
                                          ),
                                        );
                                      }
                                    }
                                  },
                                  child: const Text("Devre Dışı Bırak"),
                                ),
                              ],
                            ),
                      );
                    },
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 4,
                      color: Colors.white,
                      child: const ListTile(
                        leading: Icon(Icons.block, color: Colors.black),
                        title: Text('Hesabı Devre Dışı Bırak'),
                        textColor: Colors.black,
                        trailing: Icon(Icons.arrow_forward_ios, size: 16),
                      ),
                    ),
                  ),
                ],
              );
            } else {
              return const Center(child: Text('Kullanıcı bilgisi bulunamadı.'));
            }
          },
        ),
      ),
    );
  }
}

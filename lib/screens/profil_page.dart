import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ProfilPage extends StatelessWidget {
  const ProfilPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF5F7FA),

      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.blue,
        centerTitle: true,
        title: const Text(
          "Profil",
          style: TextStyle(color: Colors.white),
        ),
      ),

      body: SingleChildScrollView(
        child: Column(
          children: [

            Container(
              width: double.infinity,
              padding: const EdgeInsets.only(bottom: 30),
              decoration: const BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),

              child: const Column(
                children: [

                  SizedBox(height: 20),

                  CircleAvatar(
                    radius: 55,
                    backgroundColor: Colors.white,
                    child: Icon(
                      Icons.person,
                      size: 60,
                      color: Colors.blue,
                    ),
                  ),

                  SizedBox(height: 15),

                  Text(
                    "Wili",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  SizedBox(height: 5),

                  Text(
                    "admin@gmail.com",
                    style: TextStyle(
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            Card(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                children: [

                  ListTile(
                    leading: const Icon(Icons.person),
                    title: const Text("Nama"),
                    subtitle: const Text("Wili"),
                  ),

                  const Divider(height: 1),

                  ListTile(
                    leading: const Icon(Icons.email),
                    title: const Text("Email"),
                    subtitle: const Text("wili@gmail.com"),
                  ),

                  const Divider(height: 1),

                  ListTile(
                    leading: const Icon(Icons.phone),
                    title: const Text("Nomor HP"),
                    subtitle: const Text("081234567890"),
                  ),

                  const Divider(height: 1),

                  ListTile(
                    leading: const Icon(Icons.location_on),
                    title: const Text("Alamat"),
                    subtitle: const Text("Indonesia"),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            Card(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                children: [

                  ListTile(
                    leading: const Icon(Icons.lock),
                    title: const Text("Ubah Password"),
                    trailing: const Icon(Icons.arrow_forward_ios,size:16),
                    onTap: () {},
                  ),

                  const Divider(height: 1),

                  ListTile(
                    leading: const Icon(Icons.settings),
                    title: const Text("Pengaturan"),
                    trailing: const Icon(Icons.arrow_forward_ios,size:16),
                    onTap: () {},
                  ),

                  const Divider(height: 1),

                  ListTile(
                    leading: const Icon(
                      Icons.logout,
                      color: Colors.red,
                    ),
                    title: const Text(
                      "Logout",
                      style: TextStyle(color: Colors.red),
                    ),
                    trailing: const Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: Colors.red,
                    ),
                    onTap: () {

                      showDialog(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: const Text("Logout"),
                          content: const Text(
                            "Apakah Anda yakin ingin logout?"
                          ),
                          actions: [

                            TextButton(
                              onPressed: (){
                                Navigator.pop(context);
                              },
                              child: const Text("Batal"),
                            ),

                            ElevatedButton(
                              onPressed: (){
                                context.go('/login');
                              },
                              child: const Text("Logout"),
                            )

                          ],
                        ),
                      );

                    },
                  ),

                ],
              ),
            ),

            const SizedBox(height: 30),

          ],
        ),
      ),
    );
  }
}
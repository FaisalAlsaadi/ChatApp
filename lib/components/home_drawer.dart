import 'package:chatapp/services/auth_service.dart';
import 'package:chatapp/pages/settings_page.dart';
import 'package:flutter/material.dart';

class HomeDrawer extends StatelessWidget {
  const HomeDrawer({super.key});

  //logout function
  void logout() {
    //get auth service
    final auth = AuthService();
    auth.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor:
          Theme.of(context).colorScheme.surface,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          //home list tiles
          Column(
            children: [
              //logo
              DrawerHeader(
                child: Icon(
                  Icons.message,
                  color:
                      Theme.of(context).colorScheme.primary,
                  size: 50,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 25.0),
                child: ListTile(
                  title: const Text("H O M E"),
                  leading: Icon(Icons.home),
                  //pop drawer
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
              ),

              //settings
              Padding(
                padding: const EdgeInsets.only(left: 25.0),
                child: ListTile(
                  title: const Text("S E T T I N G S"),
                  leading: const Icon(Icons.settings),
                  //pop and navigate to settings page
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (ctx) => SettingsPage(),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),

          //logout
          Padding(
            padding: const EdgeInsets.only(
              left: 25.0,
              bottom: 25,
            ),
            child: ListTile(
              title: const Text("L O G O U T"),
              leading: const Icon(Icons.logout),
              onTap: logout,
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:chatapp/chat_services/chat_services.dart';
import 'package:chatapp/components/health_reminder.dart';
import 'package:chatapp/components/home_drawer.dart';
import 'package:chatapp/components/user_tile.dart';
import 'package:chatapp/pages/chat_page.dart';
import 'package:chatapp/services/auth_service.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Chat and auth services
  final ChatServices _chatServices = ChatServices();
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    
    // Schedule the check for health reminder after the widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAndShowHealthReminder();
    });
  }

  // Check and show health reminder if needed
  Future<void> _checkAndShowHealthReminder() async {
    await HealthReminderDialog.show(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home', textAlign: TextAlign.center),
      ),
      drawer: const HomeDrawer(),
      body: _buildUserList(),
    );
  }

  // Build a list of users except for the current logged in user
  Widget _buildUserList() {
    return StreamBuilder(
      stream: _chatServices.getUsersStream(),
      builder: (context, snapshot) {
        // Error
        if (snapshot.hasError) {
          return const Text("Error");
        }

        // Loading
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Text("Loading..");
        }

        // Return listview
        return ListView(
          children: snapshot.data!
              .map<Widget>(
                (userData) => _buildUserListItem(
                  userData,
                  context,
                ),
              )
              .toList(),
        );
      },
    );
  }

  // Build individual list tile for a user
  Widget _buildUserListItem(
    Map<String, dynamic> userData,
    BuildContext context,
  ) {
    // Display all users except current user
    if (userData["email"] != _authService.getCurrentUser()!.email) {
      return UserTile(
        text: userData["email"],
        onTap: () {
          // Tap on user -> go to chat page
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChatPage(
                receiverEmail: userData["email"],
                receiverID: userData["uid"],
              ),
            ),
          );
        },
      );
    } else {
      return Container();
    }
  }
}
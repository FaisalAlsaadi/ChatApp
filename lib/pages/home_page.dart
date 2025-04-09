import 'package:chatapp/chat_services/chat_services.dart';
import 'package:chatapp/components/home_drawer.dart';
import 'package:chatapp/components/user_tile.dart';
import 'package:chatapp/pages/chat_page.dart';
import 'package:chatapp/services/auth_service.dart';
import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  HomePage({super.key});

  // chat and auth services
  final ChatServices _chatServices = ChatServices();
  final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home', textAlign: TextAlign.center),
      ),
      drawer: const HomeDrawer(),
      body: _buildUserList(),
    );
  }

  //build a list of users except
  //for the current logged in user
  Widget _buildUserList() {
    return StreamBuilder(
      stream: _chatServices.getUsersStream(),
      builder: (context, snapshot) {
        //error
        if (snapshot.hasError) {
          return const Text("Error");
        }

        //loading
        if (snapshot.connectionState ==
            ConnectionState.waiting) {
          return const Text("Loading..");
        }

        //return listview
        return ListView(
          children:
              snapshot.data!
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

  //build individual list tile for a user

  Widget _buildUserListItem(
    Map<String, dynamic> userData,
    BuildContext context,
  ) {
    //display all users except current user
    if (userData["email"] !=
        _authService.getCurrentUser()!.email) {
      return UserTile(
        text: userData["email"],
        onTap: () {
          //tap on user -> go to chat page
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (context) => ChatPage(
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

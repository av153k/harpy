import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:harpy/api/twitter/data/user.dart';
import 'package:harpy/components/screens/login_screen.dart';
import 'package:harpy/components/screens/settings_screen.dart';
import 'package:harpy/components/screens/user_profile_screen.dart';
import 'package:harpy/components/widgets/shared/misc.dart';
import 'package:harpy/components/widgets/shared/service_provider.dart';
import 'package:harpy/core/misc/harpy_navigator.dart';
import 'package:harpy/models/login_model.dart';

/// The [Drawer] shown in the [HomeScreen].
///
/// It displays the logged in [User] on the top and allows to navigate to
/// different parts of the app and logout.
class HomeDrawer extends StatelessWidget {
  Future<void> _logoutAndNavigateBack(BuildContext context) async {
    final loginModel = LoginModel.of(context);
    await loginModel.logout();

    HarpyNavigator.pushReplacement(context, LoginScreen());
  }

  Widget _buildActions(BuildContext context) {
    final loginModel = LoginModel.of(context);
    final directoryService = ServiceProvider.of(context).data.directoryService;

    return Column(
      children: <Widget>[
        // profile
        ListTile(
          leading: Icon(Icons.face),
          title: Text("Profile"),
          onTap: () async {
            await Navigator.of(context).maybePop();
            HarpyNavigator.push(
              context,
              UserProfileScreen(user: loginModel.loggedInUser),
            );
          },
        ),

        // clear cache // todo: shouldn't be in home drawer, instead in settings
        ListTile(
          leading: Icon(Icons.close),
          title: Text("Clear cache"),
          onTap: () {
            int deletedFiles = directoryService.clearCache();
            Navigator.of(context).maybePop();
            Scaffold.of(context).showSnackBar(SnackBar(
              content: Text("Deleted $deletedFiles cached files"),
            ));
          },
        ),

        Divider(),

        // settings
        ListTile(
          leading: Icon(Icons.settings),
          title: Text("Settings"),
          onTap: () async {
            await Navigator.of(context).maybePop();
            HarpyNavigator.push(context, SettingsScreen());
          },
        ),

        Expanded(child: Container()),

        ListTile(
          leading: Icon(Icons.arrow_back),
          title: Text("Logout"),
          onTap: () => _logoutAndNavigateBack(context),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final loginModel = LoginModel.of(context);

    return Drawer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          UserDrawerHeader(loginModel.loggedInUser),
          Expanded(child: _buildActions(context)),
        ],
      ),
    );
  }
}

/// The [UserDrawerHeader] that contains information about the logged in [User].
class UserDrawerHeader extends StatelessWidget {
  const UserDrawerHeader(this.user);

  final User user;

  Widget _buildAvatarRow(BuildContext context) {
    final loginModel = LoginModel.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        // tappable circle avatar
        GestureDetector(
          onTap: () {
            HarpyNavigator.push(
              context,
              UserProfileScreen(user: loginModel.loggedInUser),
            );
          },
          child: CircleAvatar(
            radius: 32.0,
            backgroundColor: Colors.transparent,
            backgroundImage: CachedNetworkImageProvider(
              user.userProfileImageOriginal,
            ),
          ),
        ),

        SizedBox(width: 16.0),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              GestureDetector(
                onTap: () {
                  HarpyNavigator.push(
                    context,
                    UserProfileScreen(user: loginModel.loggedInUser),
                  );
                },
                child: Text(
                  user.name,
                  style: Theme.of(context).textTheme.display2,
                ),
              ),
              GestureDetector(
                onTap: () {
                  HarpyNavigator.push(
                    context,
                    UserProfileScreen(user: loginModel.loggedInUser),
                  );
                },
                child: Text(
                  "@${user.screenName}",
                  style: Theme.of(context).textTheme.display1,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8.0),
      padding: EdgeInsets.fromLTRB(
        16.0,
        16.0 + MediaQuery.of(context).padding.top, // + statusbar height
        16.0,
        8.0,
      ),
      decoration: BoxDecoration(
        border: Border(
          bottom: Divider.createBorderSide(context),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _buildAvatarRow(context),
          SizedBox(height: 16.0),
          FollowersCount(
            followers: user.followersCount, // todo: limit number
            following: user.friendsCount, // todo: limit number
          ),
        ],
      ),
    );
  }
}
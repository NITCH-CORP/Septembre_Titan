//import 'package:babstrap_settings_screen/babstrap_settings_screen.dart';
import 'package:flutter/material.dart';
//import 'package:device_preview/device_preview.dart';
//import 'package:example/screens/gallery_screen.dart';
import 'package:settings_ui/settings_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingScreen extends StatefulWidget {
  const SettingScreen({super.key});

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  String accountType = '';
  void _initBackground() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    accountType = preferences.getString('accountType')!;
    setState(() {
      
    });
  }

  @override
  void initState() {
    super.initState();
    _initBackground();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white.withOpacity(.94),
      appBar: AppBar(
        leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(Icons.chevron_left, color: Colors.white)),
        title: const Text(
          "Parametre",
          style: TextStyle(
              color: Color.fromARGB(255, 255, 255, 255),
              fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.blue,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: SettingsList(
          sections: [
            SettingsSection(
              title: const Text('Common'),
              tiles: <SettingsTile>[
                SettingsTile.navigation(
                  leading: const Icon(Icons.language),
                  title: const Text('Language'),
                  value: const Text('Francais'),
                ),
                SettingsTile.navigation(
                  leading: const Icon(Icons.person),
                  title: const Text('Type Compte'),
                  value: Text(accountType),
                ),
                SettingsTile.switchTile(
                  onToggle: (value) {},
                  initialValue: true,
                  leading: const Icon(Icons.format_paint),
                  title: const Text('Enable custom theme'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/**
 *     child: ListView(
            children: [
              // user card
              SimpleUserCard(
                onTap: (){

                },
                userMoreInfo: Container(width:40,height:40,decoration: const BoxDecoration(color:Colors.red),),
                userName: "Jr Stan",
                userProfilePic: const AssetImage("assets/images/user.png"),
              ),
              SettingsGroup(
                items: [
                  SettingsItem(
                    onTap: () {},
                    icons: CupertinoIcons.pencil_outline,
                    iconStyle: IconStyle(
                      backgroundColor: Colors.blue,
                    ),
                    title: 'Apparance',
                    subtitle: "Nitch Corp App",
                  ),
                  SettingsItem(
                    onTap: () {},
                    icons: Icons.fingerprint,
                    iconStyle: IconStyle(
                      iconsColor: Colors.white,
                      withBackground: true,
                      backgroundColor: Colors.blue,
                    ),
                    title: 'Langue',
                    subtitle: "Francais",
                  ),
                  SettingsItem(
                    onTap: () {},
                    icons: Icons.dark_mode_rounded,
                    iconStyle: IconStyle(
                      iconsColor: Colors.white,
                      withBackground: true,
                      backgroundColor: Colors.blue,
                    ),
                    title: 'Mode sombre',
                    subtitle: "Automatic",
                    trailing: Switch.adaptive(
                      value: false,
                      onChanged: (value) {},
                    ),
                  ),
                  SettingsItem(
                    onTap: () {},
                    icons: Icons.dark_mode_rounded,
                    iconStyle: IconStyle(
                      iconsColor: Colors.white,
                      withBackground: true,
                      backgroundColor: Colors.blue,
                    ),
                    title: 'Notification',
                    subtitle: "Automatic",
                    trailing: Switch.adaptive(
                      value: false,
                      onChanged: (value) {},
                    ),
                  ),
                  SettingsItem(
                    onTap: () {},
                    icons: Icons.dark_mode_rounded,
                    iconStyle: IconStyle(
                      iconsColor: Colors.white,
                      withBackground: true,
                      backgroundColor: Colors.blue,
                    ),
                    title: 'Lieu Favoris',
                    subtitle: "Automatic",
                    trailing: Switch.adaptive(
                      value: false,
                      onChanged: (value) {},
                    ),
                  ),
                ],
              ),
              SettingsGroup(
                items: [
                  SettingsItem(
                    onTap: () {},
                    icons: Icons.info_rounded,
                    iconStyle: IconStyle(
                      backgroundColor: Colors.blue,
                    ),
                    title: 'A Propos',
                    subtitle: "Savoir plus sur l'application",
                  ),
                ],
              ),
              // You can add a settings title
              SettingsGroup(
                settingsGroupTitle: "Compte",
                items: [
                  SettingsItem(
                    onTap: () {},
                    icons: Icons.exit_to_app_rounded,
                    iconStyle: IconStyle(
                      backgroundColor: Colors.blue,
                    ),
                    title: "Se Deconnecter",
                  ),
                  SettingsItem(
                    onTap: () {},
                    icons: CupertinoIcons.repeat,
                    iconStyle: IconStyle(
                      backgroundColor: Colors.blue,
                    ),
                    title: "Modifier ses information",
                  ),
                  /*SettingsItem(
                    onTap: () {},
                    icons: CupertinoIcons.delete_solid,
                    iconStyle: IconStyle(
                      backgroundColor: Colors.blue,
                    ),
                    title: "Supprimer son compte",
                    titleStyle: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),*/
                ],
              ),
            ],
          ),
 */
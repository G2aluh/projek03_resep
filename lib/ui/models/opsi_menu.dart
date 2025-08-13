import 'package:flutter/material.dart';

class OpsiMenu {
  final String value;
  final String title;
  final IconData icon;

  OpsiMenu({required this.value, required this.title, required this.icon});

  static List<OpsiMenu> opsiMenu = [
    OpsiMenu(value: 'profile', title: 'Profil', icon: Icons.person),
    OpsiMenu(value: 'bookmark', title: 'Bookmark', icon: Icons.bookmark),
    OpsiMenu(
      value: 'notification',
      title: 'Notification',
      icon: Icons.notifications,
    ),
    OpsiMenu(value: 'settings', title: 'Settings', icon: Icons.settings),
    OpsiMenu(value: 'exit', title: 'Exit', icon: Icons.exit_to_app),
  ];
}
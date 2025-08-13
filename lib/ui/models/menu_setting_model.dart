import 'package:flutter/material.dart';
import 'package:resep/ui/screens/language.dart';
import 'package:resep/ui/screens/notification.dart';

class MenuSettingModel {
  UniqueKey? id = UniqueKey();
  final String title;
  final IconData? icon;
  final Route<dynamic> Function(BuildContext)? route;
  final Map<String, dynamic>? content;

  MenuSettingModel({
    this.id,
    this.title = "",
    this.icon,
    this.route,
    this.content,
  });

  static List<MenuSettingModel> menuSetting = [
    MenuSettingModel(
      title: "Bahasa",
      icon: Icons.translate,
      route: (_) => MaterialPageRoute(
        builder: (_) => const LanguagePage(initLanguage: "Indonesia"),
      ),
      content: {
        "language": ["Indonesia", "Melayu", "Bonsaki", "China"],
      },
    ),
    MenuSettingModel(
      title: "Notifikasi",
      icon: Icons.notifications_none,
      route: (_) => MaterialPageRoute(builder: (_) => const NotificationSetting()),
      content: {
        "notifikasi": [
          {"title": "Reaksi", "enabled": false},
          {"title": "Bookmark", "enabled": false},
          {"title": "Komentar", "enabled": true},
          {"title": "Sebutan", "enabled": false},
          {"title": "System", "enabled": false},
        ],
      },
    ),
  ];

  List<String> get languages =>
      ((content?['language'] ?? []) as List).cast<String>();
}
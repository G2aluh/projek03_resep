import 'package:flutter/material.dart';
import 'package:resep/ui/components/menu_setting.dart';
import 'package:resep/ui/models/menu_setting_model.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final setting = MenuSettingModel.menuSetting;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back),
        ),
        title: const Text(
          'Pengaturan',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
        ),
        centerTitle: false,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: ListView.builder(
        itemCount: setting.length,
        itemBuilder: (context, index) {
          return MenuSettingComponent(menuSetting: setting[index]);
        },
      ),
    );
  }
}
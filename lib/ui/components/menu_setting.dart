import 'package:flutter/material.dart';
import 'package:resep/ui/models/menu_setting_model.dart';

class MenuSettingComponent extends StatelessWidget {
  const MenuSettingComponent({Key? key, required this.menuSetting})
    : super(key: key);

  final MenuSettingModel menuSetting;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          if (menuSetting.route != null) {
            Navigator.push(context, menuSetting.route!(context));
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(menuSetting.icon, size: 28),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  menuSetting.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:resep/ui/models/menu_setting_model.dart';

class LanguagePage extends StatefulWidget {
  final String initLanguage;

  const LanguagePage({Key? key, required this.initLanguage}) : super(key: key);

  @override
  State<LanguagePage> createState() => _LanguagePageState();
}

class _LanguagePageState extends State<LanguagePage> {
  late final MenuSettingModel settingLang;
  late String langSelected;
  late List<String> orderedLang;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    settingLang = MenuSettingModel.menuSetting.firstWhere(
      (e) => e.title == "Bahasa",
    );
    orderedLang = List.from(settingLang.languages);
    langSelected = orderedLang.contains(widget.initLanguage)
        ? widget.initLanguage
        : orderedLang.first;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(settingLang.title),
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context, langSelected);
            },
            child: const Text(
              "Selesai",
              style: TextStyle(fontSize: 16, color: Colors.black),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              decoration: InputDecoration(
                hintText: "Search language",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: orderedLang.length,
              itemBuilder: (context, index) {
                final lang = orderedLang[index];
                return ListTile(
                  title: Text(lang),
                  trailing: langSelected == lang
                      ? const Icon(Icons.check_circle_outline_outlined)
                      : null,
                  onTap: () {
                    setState(() {
                      langSelected = lang;
                    });
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:resep/ui/screens/login.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  await Supabase.initialize(
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImVuY2N2dWVheWxxbWhxZHp6cWx1Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzMxNTQ0MDAsImV4cCI6MjA0ODczMDQwMH0.sU4SdsRb2acqRkJywMpO5iEqAShn2L5Rfjxxn1Zy0K4',
    url: 'https://enccvueaylqmhqdzzqlu.supabase.co',
  );
  runApp(const ResepApp());
}

class ResepApp extends StatelessWidget {
  const ResepApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false, 
      home: Login());
  }
}

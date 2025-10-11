import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// 기존: 배경 아이템 업로드
Future<void> importItemsFromJson() async {
  final db = FirebaseFirestore.instance;
  final String jsonString = await rootBundle.loadString('assets/data/items_blocks.json');
  final List<dynamic> items = jsonDecode(jsonString);

  for (final item in items) {
    final id = item['id'];
    await db.collection('items').doc(id).set({
      ...item,
      'created_at': FieldValue.serverTimestamp(),
    });
    print('✅ Uploaded item: $id');
  }

  print('🔥 All background items uploaded successfully!');
}

/// 신규: 세트 효과 업로드
Future<void> importItemSetsFromJson() async {
  final db = FirebaseFirestore.instance;
  final String jsonString = await rootBundle.loadString('assets/data/item_sets.json');
  final List<dynamic> sets = jsonDecode(jsonString);

  for (final set in sets) {
    final id = set['id'];
    await db.collection('item_sets').doc(id).set({
      ...set,
      'created_at': FieldValue.serverTimestamp(),
    });
    print('✅ Uploaded set: $id');
  }

  print('🔥 All item sets uploaded successfully!');
}
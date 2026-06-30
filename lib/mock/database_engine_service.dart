// ignore_for_file: avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';
import 'kivomap_mock_data.dart';

class DatabaseEngineService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// PHẦN 1: Bơm nguyên liệu bài học tĩnh (Chỉ cần chạy 1 lần duy nhất)
  Future<void> seedStaticKnowledgeBase() async {
    try {
      print("🚀 [KivoMap Engine] Đang xây kho dữ liệu bài học tĩnh...");

      // Kiểm tra tránh trùng lặp nếu đã chạy lệnh trước đó
      final existingClusters = await _firestore
          .collection('knowledge_clusters')
          .where('title', isEqualTo: seedCluster['title'])
          .get();

      if (existingClusters.docs.isNotEmpty) {
        print("💡 Kho dữ liệu bài học đã tồn tại. Bỏ qua bước seed dữ liệu tĩnh.");
        return;
      }

      // Tạo Cluster gốc
      DocumentReference clusterRef = await _firestore
          .collection('knowledge_clusters')
          .add(seedCluster);
      String clusterId = clusterRef.id;

      // Nạp cụm từ vựng mục tiêu (Sub-collection)
      for (var vocab in seedVocabularies) {
        String vocabId = vocab['id'];
        Map<String, dynamic> vocabData = Map.from(vocab)..remove('id');

        await _firestore
            .collection('knowledge_clusters')
            .doc(clusterId)
            .collection('vocabularies')
            .doc(vocabId)
            .set(vocabData);
      }

      // Nạp ma trận câu hỏi bối cảnh đục lỗ bằng Batch Write
      final batch = _firestore.batch();
      for (var link in seedLinks) {
        link['clusterId'] = clusterId;
        DocumentReference linkRef = _firestore.collection('knowledge_links').doc();
        batch.set(linkRef, link);
      }
      await batch.commit();

      print("🎉 [KivoMap Engine] Khởi tạo kho dữ liệu bài học tĩnh THÀNH CÔNG!");
    } catch (e) {
      print("❌ Lỗi kích hoạt dữ liệu tĩnh: $e");
    }
  }

  /// PHẦN 2: Tự động kích hoạt hồ sơ động cho User mới khi đăng nhập (Học để dùng)
  Future<void> activateUserRuntimeEnvironment({
    required String userId,
    required String name,
    required String email,
  }) async {
    try {
      final userRef = _firestore.collection('users').doc(userId);
      final snapshot = await userRef.get();

      if (!snapshot.exists) {
        print("👤 [KivoMap Engine] Phát hiện User mới. Đang cấu hình tài khoản...");

        await userRef.set({
          'name': name,
          'email': email,
          'isNewbieDiscover': true, // Phục vụ luật BR-D11 lật hé lộ thẻ [cite: 239]
          'createdAt': FieldValue.serverTimestamp(),

          // Nhúng trực tiếp cấu trúc Dashboard phẳng để tối ưu chi phí (0 đồng) [cite: 566]
          'progress': {
            'learnedWords': 0,
            'reviewedWords': 0,
            'masteryScore': 0,
            'streakDays': 1,
          }
        });
        print("🎉 [KivoMap Engine] Kích hoạt môi trường thực hành của User thành công!");
      }
    } catch (e) {
      print("❌ Lỗi kích hoạt môi trường User: $e");
    }
  }
}

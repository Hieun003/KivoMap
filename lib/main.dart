import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'mock/database_engine_service.dart';

void main() async {
  // Đảm bảo các tiến trình hệ thống của Flutter chạy đồng bộ ổn định
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();

  // Khởi tạo kết nối lên mây với Firebase (đã vượt qua vòng Gradle 8.7.3 thành công)
  await Firebase.initializeApp();

  // ⚡ GỌI ENGINE ĐỂ XÂY DỰNG TOÀN DIỆN DATABASE KHÔNG THIẾU THỨ GÌ
  final dbEngine = DatabaseEngineService();

  // 1. Tạo kho bài học bối cảnh phẳng
  await dbEngine.seedStaticKnowledgeBase();

  // 2. Giả lập tạo luôn 1 môi trường User động chạy thử ngay lập tức (Để Test)
  // Sau này khi viết màn hình Login, bạn sẽ bê hàm này đặt sau nút bấm Auth Google/Facebook
  await dbEngine.activateUserRuntimeEnvironment(
    userId: "test_user_id_123",
    name: "KivoMap Developer",
    email: "dev.kivomap@gmail.com",
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'KivoMap Language',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      home: const Scaffold(
        body: Center(
          child: Text(
            'KivoMap Database Engine Connected! 🎉',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}
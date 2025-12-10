// lib/detail_page.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DetailPage extends StatelessWidget {
  final String question; // 질문 내용 (선택 사항, 결과 화면에서 보여줄 정보)
  final String answer; // 최종 답변 (성격 설명 텍스트)

  const DetailPage({super.key, required this.question, required this.answer});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('테스트 결과'),
        backgroundColor: Colors.blueAccent,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              '당신의 성격은?',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Text(
                answer, // 최종 결과 텍스트를 표시
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 18),
              ),
            ),
            const SizedBox(height: 40),
            // 목록 페이지로 돌아가기 버튼
            ElevatedButton(
              onPressed: () {
                // 현재 화면(DetailPage)을 닫고 이전 화면(MainPage 목록)으로 돌아갑니다.
                Navigator.of(context).pop();
              },
              child: const Text('돌아가기'),
            ),
          ],
        ),
      ),
    );
  }
}
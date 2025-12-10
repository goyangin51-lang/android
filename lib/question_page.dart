// lib/question_page.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';
import 'detail_page.dart';
import 'package:firebase_analytics/firebase_analytics.dart'; // 추가

class QuestionPage extends StatefulWidget {
  final String filename;
  final String title;

  const QuestionPage({super.key, required this.filename, required this.title});

  @override
  State<QuestionPage> createState() => _QuestionPageState();
}

class _QuestionPageState extends State<QuestionPage> {
  int selectNumber = -1;
  // late 대신 빈 맵으로 초기화하여 안정성 확보
  Map<String, dynamic> questions = {};

  Future<String> loadAsset(String fileName) async {
    return await rootBundle.loadString('res/api/$fileName');
  }

  Widget _buildRadioListTile(String title, int index) {
    return ListTile(
      title: Text(title),
      leading: Radio<int>(
        value: index,
        groupValue: selectNumber,
        onChanged: (int? value) {
          setState(() {
            if (value != null) {
              selectNumber = value;
            }
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Colors.blueAccent,
      ),
      body: FutureBuilder(
        future: loadAsset(widget.filename),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.connectionState == ConnectionState.done &&
              snapshot.hasData) {
            questions = jsonDecode(snapshot.data!) as Map<String, dynamic>;
            List<dynamic> selects = questions['questions'][0]['selects'];

            List<Widget> radioWidgets = List<Widget>.generate(
              selects.length,
                  (index) => _buildRadioListTile(
                selects[index].toString(),
                index,
              ),
            );

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    questions['questions'][0]['question'].toString(),
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: ListView.builder(
                      itemCount: radioWidgets.length,
                      itemBuilder: (context, index) {
                        return radioWidgets[index];
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: ElevatedButton(
                      onPressed: selectNumber == -1
                          ? null
                          : () async { // async로 변경
                        // [Firebase Analytics] 'personal_select' 이벤트 기록
                        await FirebaseAnalytics.instance.logEvent(
                            name: 'personal_select',
                            parameters: {
                              'select_number': selectNumber,
                              'test_title': widget.title,
                            }
                        );

                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (context) => DetailPage(
                              answer: questions['questions'][0]['answer'][selectNumber].toString(),
                              question: questions['questions'][0]['question'].toString(),
                            ),
                          ),
                        );
                      },
                      child: const Text('성격 보기'),
                    ),
                  ),
                ],
              ),
            );
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}
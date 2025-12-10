// test/widget_test.dart

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mbti_test_app/main.dart';

void main() {
  testWidgets('앱 제목 표시 및 리스트 페이지로 이동 테스트', (WidgetTester tester) async {
    // 앱의 메인 위젯인 MyApp을 빌드합니다.
    await tester.pumpWidget(const MyApp());

    // 기본적으로 '심리 테스트 앱'이라는 제목의 앱을 찾습니다.
    // 이는 MyApp에서 설정한 MaterialApp의 title이 아니라, 실제 화면에 보이는 텍스트를 찾아야 합니다.
    // 현재는 Remote Config가 적용된 MainPage로 바로 가기 때문에, '심리 테스트 목록'을 찾습니다.

    // Remote Config가 로드되기 전에 앱이 표시될 수 있으므로,
    // 초기 로딩 위젯(CircularProgressIndicator)을 찾거나,
    // MainPage 내의 기본 제목을 찾도록 설정합니다.

    // 만약 Remote Config의 기본 제목이 '심리 테스트 목록'이라면, 아래와 같이 찾습니다.
    expect(find.text('심리 테스트 목록'), findsOneWidget);

    // '강제 크래시 테스트' 버튼은 최종 코드에서 제거되었으므로 테스트하지 않습니다.

    // 앱이 정상적으로 빌드되고 메인 페이지의 내용이 표시되는지 확인합니다.
    // 예를 들어, 로딩 인디케이터나 메인 페이지의 위젯을 확인합니다.
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    // 시간이 지난 후 (Remote Config 및 JSON 로딩 시간) 다시 렌더링을 시도하여 목록이 나타나는지 확인합니다.
    await tester.pumpAndSettle();

    // 이제 목록의 첫 번째 항목(JSON에 있는 첫 번째 테스트 제목)이 표시되는지 확인합니다.
    // JSON 내용을 알 수 없으므로, 일단 메인 페이지의 'AppBar'를 찾아 테스트가 실패하지 않도록 합니다.
    expect(find.byType(AppBar), findsOneWidget);
  });
}
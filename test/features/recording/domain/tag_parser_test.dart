import 'package:flutter_test/flutter_test.dart';
import 'package:dottie/features/recording/domain/tag_parser.dart';

void main() {
  group('TagParser.extractFromText', () {
    test('단일 한글 태그 추출', () {
      expect(TagParser.extractFromText('점심 #회의'), ['회의']);
    });

    test('다중 태그 + 순서 보존', () {
      expect(
        TagParser.extractFromText('#회의 점심 #피곤 #회의'),
        ['회의', '피곤'],
      );
    });

    test('영문/숫자/언더스코어 허용', () {
      expect(
        TagParser.extractFromText('#cafe2024 #morning_run'),
        ['cafe2024', 'morning_run'],
      );
    });

    test('lowercase 정규화', () {
      expect(TagParser.extractFromText('#Café #MEETING'),
          ['café', 'meeting']);
    });

    test('특수문자/공백 종료', () {
      expect(TagParser.extractFromText('#회의-끝났음'), ['회의']);
      expect(TagParser.extractFromText('아침 # 빈태그'), isEmpty);
    });

    test('빈 입력', () {
      expect(TagParser.extractFromText(null), isEmpty);
      expect(TagParser.extractFromText(''), isEmpty);
      expect(TagParser.extractFromText('태그없는 메모'), isEmpty);
    });

    test('30자 초과 매칭 안 됨', () {
      final long = 'a' * 31;
      expect(TagParser.extractFromText('#$long'), isEmpty);
    });

    test('10개 cap', () {
      final memo = List.generate(15, (i) => '#tag$i').join(' ');
      expect(TagParser.extractFromText(memo).length, 10);
    });
  });

  group('TagParser.normalize', () {
    test('lowercase + trim', () {
      expect(TagParser.normalize('  Hello '), 'hello');
    });

    test('빈/공백/너무 김 → null', () {
      expect(TagParser.normalize(''), isNull);
      expect(TagParser.normalize('   '), isNull);
      expect(TagParser.normalize('a' * 31), isNull);
    });

    test('허용문자 외 → null', () {
      expect(TagParser.normalize('hello world'), isNull);
      expect(TagParser.normalize('hello-world'), isNull);
    });
  });

  group('TagParser.tokenize', () {
    test('태그/일반 텍스트 분리', () {
      final tokens = TagParser.tokenize('점심 #회의 후');
      expect(tokens.length, 3);
      expect(tokens[0], (text: '점심 ', isTag: false));
      expect(tokens[1], (text: '#회의', isTag: true));
      expect(tokens[2], (text: ' 후', isTag: false));
    });

    test('태그로 시작', () {
      final tokens = TagParser.tokenize('#시작 본문');
      expect(tokens.first, (text: '#시작', isTag: true));
    });

    test('빈 입력', () {
      expect(TagParser.tokenize(''), isEmpty);
    });
  });

  group('TagParser.activePrefix', () {
    test('태그 입력 중', () {
      expect(TagParser.activePrefix('점심 #회', 5), '회');
    });

    test('# 직후 → 빈 문자열', () {
      expect(TagParser.activePrefix('점심 #', 4), '');
    });

    test('공백 뒤 → null', () {
      expect(TagParser.activePrefix('점심 #회의 추가', 8), isNull);
    });

    test('# 없음 → null', () {
      expect(TagParser.activePrefix('점심 회의', 4), isNull);
    });

    test('Café 같은 lowercase 변환', () {
      expect(TagParser.activePrefix('#Caf', 4), 'caf');
    });
  });
}

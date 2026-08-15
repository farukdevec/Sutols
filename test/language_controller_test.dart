import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sutol/services/ip_location_service.dart';
import 'package:sutol/state/language_controller.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    LanguageController.instance.isManuallySelected = false;
    LanguageController.instance.detectedLocationInfo = null;
  });

  test('Türkiye IP adresi tespit edildiğinde varsayılan dil Türkçe olur', () async {
    final mockClient = MockClient((request) async {
      return http.Response(
        jsonEncode({
          'success': true,
          'city': 'İstanbul',
          'region': 'İstanbul',
          'country': 'Türkiye',
          'country_code': 'TR',
        }),
        200,
        headers: {'content-type': 'application/json; charset=utf-8'},
      );
    });

    final controller = LanguageController.instance;
    await controller.resetToAutoDetect(
      locationService: IpLocationService(client: mockClient),
    );

    expect(controller.currentLanguage.value, AppLanguage.tr);
    expect(controller.languageCode, 'tr');
    expect(controller.aiLanguage, 'turkish');
    expect(controller.detectedLocationInfo, contains('Türkiye'));
  });

  test('Türkiye dışı IP adresi tespit edildiğinde varsayılan dil İngilizce olur', () async {
    final mockClient = MockClient((request) async {
      return http.Response(
        jsonEncode({
          'success': true,
          'city': 'New York',
          'region': 'NY',
          'country': 'United States',
          'country_code': 'US',
        }),
        200,
        headers: {'content-type': 'application/json; charset=utf-8'},
      );
    });

    final controller = LanguageController.instance;
    await controller.resetToAutoDetect(
      locationService: IpLocationService(client: mockClient),
    );

    expect(controller.currentLanguage.value, AppLanguage.en);
    expect(controller.languageCode, 'en');
    expect(controller.aiLanguage, 'english');
    expect(controller.detectedLocationInfo, contains('United States'));
  });

  test('Kullanıcı dili manuel değiştirdiğinde SharedPreferences kaydı yapılır', () async {
    final controller = LanguageController.instance;
    await controller.setLanguage(AppLanguage.en);

    expect(controller.currentLanguage.value, AppLanguage.en);
    expect(controller.isManuallySelected, isTrue);

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('language_code'), 'en');

    // Yeni yüklemede kaydedilen tercih korunmalıdır.
    await controller.init();
    expect(controller.currentLanguage.value, AppLanguage.en);
  });
}

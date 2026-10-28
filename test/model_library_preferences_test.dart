import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sutol/services/model_library_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => SharedPreferences.setMockInitialValues({}));
  test('favorites and recent models persist by owner with stable IDs',
      () async {
    final a = ModelLibraryPreferences('a');
    await a.toggleFavorite('water');
    await a.recordUse('water');
    await a.recordUse('atom');
    await a.recordUse('water');
    final reopened = ModelLibraryPreferences('a');
    await reopened.load();
    expect(reopened.favorites, {'water'});
    expect(reopened.recent, ['water', 'atom']);
    final b = ModelLibraryPreferences('b');
    await b.load();
    expect(b.favorites, isEmpty);
    expect(b.recent, isEmpty);
    await reopened.toggleFavorite('water');
    await a.load();
    expect(a.favorites, isEmpty);
  });
  test('rapid writes retain latest order and recent history is bounded',
      () async {
    final a = ModelLibraryPreferences('a');
    await Future.wait([for (var i = 0; i < 40; i++) a.recordUse('id-$i')]);
    final reopened = ModelLibraryPreferences('a');
    await reopened.load();
    expect(reopened.recent.length, 30);
    expect(reopened.recent.first, 'id-39');
    expect(reopened.recent.last, 'id-10');
  });
}

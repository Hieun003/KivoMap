import 'package:flutter_test/flutter_test.dart';
import 'package:kivo_map/data/energy_service.dart';
import 'package:kivo_map/data/user_session_scope_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  final scope = UserSessionScopeService();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    scope.bind(null);
  });

  tearDown(() {
    scope.bind(null);
  });

  test('scopes local learning state by authenticated uid', () async {
    final energy = EnergyService();
    addTearDown(energy.dispose);

    scope.bind('user-a');
    await energy.initialize();
    await energy.consumeEnergy(5);
    expect(energy.energy.value, 45);

    scope.bind('user-b');
    await energy.initialize();
    expect(energy.energy.value, EnergyService.maxEnergy);

    scope.bind('user-a');
    await energy.initialize();
    expect(energy.energy.value, 45);
  });
}

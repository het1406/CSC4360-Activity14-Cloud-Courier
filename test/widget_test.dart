import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_courier/models/courier_state.dart';

void main() {
  test(
    'all UI lifecycle paths apply valid data and track repeated messages',
    () {
      final state = CourierState();
      for (final handler in [
        'onMessage',
        'onMessageOpenedApp',
        'getInitialMessage',
      ]) {
        state.receive(handler, 'id-$handler', {
          'action': 'update_ui',
          'asset': 'promo',
        });
        expect(state.handler, handler);
        expect(state.messageId, 'id-$handler');
        expect(state.assetPath, 'assets/images/promo.png');
        expect(state.title, 'New promotion');
      }
      expect(state.count, 3);
      state.receive('onMessage', null, {
        'action': 'update_ui',
        'asset': 'default',
      });
      expect(state.title, 'Ready for delivery');
      expect(state.assetPath, 'assets/images/default.png');
    },
  );
  test('invalid payloads preserve UI while updating receipt metadata', () {
    final state = CourierState()
      ..receive('onMessage', 'valid', {
        'action': 'update_ui',
        'asset': 'promo',
      });
    final invalid = <Map<String, dynamic>>[
      {'action': 'update_ui'},
      {'action': 'update_ui', 'asset': 'unknown'},
      {'action': 'wrong', 'asset': 'default'},
      {'action': 'update_ui', 'asset': 1},
      {'action': 'update_ui', 'asset': '../../secret'},
      {},
      {'action': 'update_ui', 'asset': 'default', 'extra': 'no'},
    ];
    for (final data in invalid) {
      state.receive('onMessage', 'invalid', data);
      expect(state.assetPath, 'assets/images/promo.png');
      expect(state.title, 'New promotion');
      expect(state.diagnostic, startsWith('Rejected:'));
      expect(state.messageId, 'invalid');
    }
    expect(state.count, 8);
  });
}

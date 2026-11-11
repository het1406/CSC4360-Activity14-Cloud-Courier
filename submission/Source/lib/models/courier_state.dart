class CourierState {
  String title = 'Ready for delivery';
  String assetPath = 'assets/images/default.png';
  String handler = 'None';
  String? messageId;
  int count = 0;
  String diagnostic = 'Waiting for an FCM message.';

  void receive(String source, String? id, Map<String, dynamic> data) {
    handler = source;
    messageId = id;
    count++;
    const assets = {
      'default': 'assets/images/default.png',
      'promo': 'assets/images/promo.png',
    };
    if (data['action'] != 'update_ui') {
      diagnostic = 'Rejected: action must be update_ui. Previous UI preserved.';
    } else if (!data.containsKey('asset')) {
      diagnostic = 'Rejected: asset is missing. Previous UI preserved.';
    } else if (data['asset'] is! String || !assets.containsKey(data['asset'])) {
      diagnostic =
          'Rejected: unsupported asset. Use default or promo. Previous UI preserved.';
    } else if (data.keys.any((key) => key != 'action' && key != 'asset')) {
      diagnostic =
          'Rejected: only action and asset keys are supported. Previous UI preserved.';
    } else {
      assetPath = assets[data['asset']]!;
      title = data['asset'] == 'promo' ? 'New promotion' : 'Ready for delivery';
      diagnostic = 'Valid update_ui applied; event $count this launch.';
    }
  }
}

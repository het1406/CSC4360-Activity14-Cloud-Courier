import 'dart:async';
import 'package:flutter/material.dart';
import '../services/fcm_service.dart';

class CourierHome extends StatefulWidget {
  const CourierHome({super.key});
  @override
  State<CourierHome> createState() => _CourierHomeState();
}

class _CourierHomeState extends State<CourierHome> {
  late final FcmService _service;
  @override
  void initState() {
    super.initState();
    _service = FcmService()..addListener(_changed);
    unawaited(_service.initialize());
  }

  void _changed() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _service.removeListener(_changed);
    _service.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = _service.state;
    return Scaffold(
      appBar: AppBar(title: const Text('Cloud Courier')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Image.asset(state.assetPath, height: 180, fit: BoxFit.contain),
            const SizedBox(height: 16),
            Text(state.title, style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 16),
            Text('Last handler: ${state.handler}'),
            Text('Message events this launch: ${state.count}'),
            const Text('Includes foreground receipts and notification opens.'),
            SelectableText('Message ID: ${state.messageId ?? "Not provided"}'),
            const SizedBox(height: 16),
            Text(state.diagnostic),
            const Divider(),
            Text('Notification permission: ${_service.permission}'),
            Text('Device token: ${_service.tokenStatus}'),
            Text(_service.setupStatus),
          ],
        ),
      ),
    );
  }
}

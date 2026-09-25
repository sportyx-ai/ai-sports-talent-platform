import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../core/api_config.dart';

Future<void> showServerSettingsDialog(BuildContext context, {VoidCallback? onUpdated}) async {
  final controller = TextEditingController(text: ApiConfig.baseUrl);
  String? testStatus;
  Color testColor = Colors.grey;
  bool isTesting = false;

  await showDialog(
    context: context,
    builder: (ctx) => StatefulBuilder(
      builder: (context, setDialogState) {
        Future<void> runTest(String url) async {
          setDialogState(() {
            isTesting = true;
            testStatus = "Testing connection...";
            testColor = Colors.blue;
          });

          try {
            final uri = Uri.parse("${ApiConfig.normalizeUrl(url)}/api/health");
            final res = await http.get(uri).timeout(const Duration(seconds: 3));
            if (res.statusCode >= 200 && res.statusCode < 300) {
              setDialogState(() {
                testStatus = "Connected! Backend is online (HTTP ${res.statusCode})";
                testColor = Colors.green;
                isTesting = false;
              });
              return;
            } else {
              setDialogState(() {
                testStatus = "Server responded with HTTP ${res.statusCode}";
                testColor = Colors.orange;
                isTesting = false;
              });
              return;
            }
          } catch (e) {
            setDialogState(() {
              testStatus = "Connection failed. Please check network/USB.";
              testColor = Colors.red;
              isTesting = false;
            });
          }
        }

        Future<void> runAutoDetect() async {
          setDialogState(() {
            isTesting = true;
            testStatus = "Scanning available endpoints...";
            testColor = Colors.blue;
          });

          final detected = await ApiConfig.autoDetectServer();
          if (detected != null) {
            controller.text = detected;
            setDialogState(() {
              testStatus = "Found active server: $detected";
              testColor = Colors.green;
              isTesting = false;
            });
          } else {
            setDialogState(() {
              testStatus = "Could not reach server. Verify USB or Wi-Fi.";
              testColor = Colors.red;
              isTesting = false;
            });
          }
        }

        return AlertDialog(
          insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          title: const Row(
            children: [
              Icon(Icons.dns, size: 22, color: Colors.deepPurple),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  "Backend Server URL",
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ],
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    "Configure the Spring Boot backend address:",
                    style: TextStyle(fontSize: 13, color: Colors.grey),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: controller,
                    decoration: const InputDecoration(
                      labelText: "Server Base URL",
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    alignment: WrapAlignment.spaceBetween,
                    children: [
                      OutlinedButton.icon(
                        icon: const Icon(Icons.network_check, size: 16),
                        label: const Text("Test", style: TextStyle(fontSize: 12)),
                        onPressed: isTesting ? null : () => runTest(controller.text.trim()),
                      ),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.auto_fix_high, size: 16),
                        label: const Text("Auto-Detect", style: TextStyle(fontSize: 12)),
                        onPressed: isTesting ? null : runAutoDetect,
                      ),
                    ],
                  ),
                  if (testStatus != null) ...[
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: testColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: testColor.withValues(alpha: 0.4)),
                      ),
                      child: Text(
                        testStatus!,
                        style: TextStyle(fontSize: 12, color: testColor, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  const Text(
                    "Quick Presets:",
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      ActionChip(
                        avatar: const Icon(Icons.usb, size: 14),
                        label: const Text("USB (127.0.0.1:8080)", style: TextStyle(fontSize: 11)),
                        onPressed: () {
                          controller.text = "http://127.0.0.1:8080";
                          runTest("http://127.0.0.1:8080");
                        },
                      ),
                      ActionChip(
                        avatar: const Icon(Icons.wifi, size: 14),
                        label: const Text("Wi-Fi (10.190.51.170)", style: TextStyle(fontSize: 11)),
                        onPressed: () {
                          controller.text = "http://10.190.51.170:8080";
                          runTest("http://10.190.51.170:8080");
                        },
                      ),
                      ActionChip(
                        avatar: const Icon(Icons.devices, size: 14),
                        label: const Text("Emulator (10.0.2.2)", style: TextStyle(fontSize: 11)),
                        onPressed: () {
                          controller.text = "http://10.0.2.2:8080";
                          runTest("http://10.0.2.2:8080");
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () {
                final newUrl = controller.text.trim();
                if (newUrl.isNotEmpty) {
                  ApiConfig.setBaseUrl(newUrl);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Server set to: ${ApiConfig.baseUrl}")),
                  );
                  onUpdated?.call();
                }
                Navigator.pop(ctx);
              },
              child: const Text("Save"),
            ),
          ],
        );
      },
    ),
  );
}

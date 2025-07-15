import 'package:flutter/material.dart';
import 'package:reminest/services/key_service.dart';
import 'package:reminest/screens/vault_screen.dart';

class SetVaultPinScreen extends StatefulWidget {
  final VoidCallback? onComplete;

  const SetVaultPinScreen({super.key, this.onComplete});

  @override
  State<SetVaultPinScreen> createState() => _SetVaultPinScreenState();
}

class _SetVaultPinScreenState extends State<SetVaultPinScreen> {
  final _pinController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _isButtonEnabled = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _pinController.addListener(_updateButtonState);
    _confirmController.addListener(_updateButtonState);
  }

  @override
  void dispose() {
    _pinController.removeListener(_updateButtonState);
    _confirmController.removeListener(_updateButtonState);
    _pinController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  void _updateButtonState() {
    setState(() {
      _isButtonEnabled = _pinController.text.isNotEmpty && _confirmController.text.isNotEmpty;
    });
  }

  void _setPin() async {
    if (_isLoading) return;

    if (_pinController.text != _confirmController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('PINs do not match.')),
      );
      return;
    }

    if (_pinController.text.length < 4 ||
        _pinController.text.length > 6 ||
        !RegExp(r'^\d+$').hasMatch(_pinController.text)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('PIN must be 4-6 digits.')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await KeyService.saveVaultPin(_pinController.text);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Vault PIN set successfully!'),
            backgroundColor: Colors.green,
          ),
        );

        if (widget.onComplete != null) {
          widget.onComplete!();
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const VaultScreen()),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to set PIN: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Set Vault PIN'),
        backgroundColor: theme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Information section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.only(bottom: 24),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                border: Border.all(color: Colors.orange.withOpacity(0.3)),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.warning_amber, color: Colors.orange, size: 24),
                      SizedBox(width: 8),
                      Text(
                        "Important: PIN Security",
                        style: TextStyle(
                          color: Colors.orange,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "• Your vault PIN is unrecoverable\n• If forgotten, all vault data will be lost\n• Choose a PIN you'll remember (4-6 digits)",
                    style: TextStyle(
                      color: theme.textTheme.bodyMedium?.color,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            TextField(
              controller: _pinController,
              enabled: !_isLoading,
              obscureText: true,
              keyboardType: TextInputType.number,
              maxLength: 6,
              onSubmitted: (_) => _isLoading ? null : _setPin(),
              style: TextStyle(color: theme.textTheme.bodyLarge?.color),
              decoration: InputDecoration(
                hintText: 'Enter 4-6 digit PIN',
                hintStyle: TextStyle(color: theme.hintColor),
                counterText: "",
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: theme.dividerColor),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: theme.primaryColor),
                ),
                disabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: theme.dividerColor.withOpacity(0.5)),
                ),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _confirmController,
              enabled: !_isLoading,
              obscureText: true,
              keyboardType: TextInputType.number,
              maxLength: 6,
              onSubmitted: (_) => _isLoading ? null : _setPin(),
              style: TextStyle(color: theme.textTheme.bodyLarge?.color),
              decoration: InputDecoration(
                hintText: 'Confirm PIN',
                hintStyle: TextStyle(color: theme.hintColor),
                counterText: "",
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: theme.dividerColor),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: theme.primaryColor),
                ),
                disabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: theme.dividerColor.withOpacity(0.5)),
                ),
              ),
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.primaryColor,
                  foregroundColor: Colors.white,
                  elevation: 6,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: (_isButtonEnabled && !_isLoading) ? _setPin : null,
                child: _isLoading
                    ? const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          ),
                          SizedBox(width: 12),
                          Text(
                            'Setting PIN...',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      )
                    : const Text(
                        'Set PIN',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

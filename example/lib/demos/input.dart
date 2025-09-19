import 'package:flutter/cupertino.dart';
import 'package:cupertino_native/cupertino_native.dart';

class InputDemo extends StatefulWidget {
  const InputDemo({super.key});

  @override
  State<InputDemo> createState() => _InputDemoState();
}

class _InputDemoState extends State<InputDemo> {
  final TextEditingController _textController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();

  String _inputText = '';
  bool _isFocused = false;

  @override
  void dispose() {
    _textController.dispose();
    _passwordController.dispose();
    _emailController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(middle: Text('Input Demo')),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Native Input Fields',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),

              // Basic text input
              const Text('Basic Text Input:', style: TextStyle(fontSize: 18)),
              const SizedBox(height: 8),
              CNInput(
                controller: _textController,
                placeholder: 'Enter your name',
                borderStyle: CNInputBorderStyle.roundedRect,
                onChanged: (text) {
                  setState(() {
                    _inputText = text;
                  });
                },
                onFocusChanged: (focused) {
                  setState(() {
                    _isFocused = focused;
                  });
                },
              ),
              const SizedBox(height: 8),
              Text('Text: $_inputText'),
              Text('Focused: $_isFocused'),
              const SizedBox(height: 20),

              // Password input
              const Text('Password Input:', style: TextStyle(fontSize: 18)),
              const SizedBox(height: 8),
              CNInput(
                controller: _passwordController,
                placeholder: 'Enter password',
                isSecure: true,
                borderStyle: CNInputBorderStyle.roundedRect,
                textContentType: 'password',
              ),
              const SizedBox(height: 20),

              // Email input
              const Text('Email Input:', style: TextStyle(fontSize: 18)),
              const SizedBox(height: 8),
              CNInput(
                controller: _emailController,
                placeholder: 'Enter email address',
                keyboardType: TextInputType.emailAddress,
                borderStyle: CNInputBorderStyle.line,
                textContentType: 'emailAddress',
                autocorrect: false,
              ),
              const SizedBox(height: 20),

              // Search input
              const Text('Search Input:', style: TextStyle(fontSize: 18)),
              const SizedBox(height: 8),
              CNInput(
                controller: _searchController,
                placeholder: 'Search...',
                textInputAction: TextInputAction.search,
                borderStyle: CNInputBorderStyle.roundedRect,
                clearButtonMode: CNInputClearButtonMode.whileEditing,
                onSubmitted: (text) {
                  // Handle search
                  showCupertinoDialog(
                    context: context,
                    builder: (context) => CupertinoAlertDialog(
                      title: const Text('Search'),
                      content: Text('Searching for: $text'),
                      actions: [
                        CupertinoDialogAction(
                          child: const Text('OK'),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),

              // Different border styles
              const Text('Border Styles:', style: TextStyle(fontSize: 18)),
              const SizedBox(height: 8),

              const Text('No Border:'),
              const SizedBox(height: 4),
              const CNInput(
                placeholder: 'No border',
                borderStyle: CNInputBorderStyle.none,
              ),
              const SizedBox(height: 12),

              const Text('Bezel Border:'),
              const SizedBox(height: 4),
              const CNInput(
                placeholder: 'Bezel border',
                borderStyle: CNInputBorderStyle.bezel,
              ),
              const SizedBox(height: 12),

              const Text('Disabled Input:'),
              const SizedBox(height: 4),
              const CNInput(
                placeholder: 'Disabled input',
                enabled: false,
                borderStyle: CNInputBorderStyle.roundedRect,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

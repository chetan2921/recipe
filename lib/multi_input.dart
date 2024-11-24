import 'package:flutter/material.dart';


class MultiInputScreen extends StatefulWidget {
  @override
  _MultiInputScreenState createState() => _MultiInputScreenState();
}

class _MultiInputScreenState extends State<MultiInputScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<String> _inputs = [];
  int _currentStep = 0;

  void _nextInput() {
    setState(() {
      if (_controller.text.isNotEmpty) {
        _inputs.add(_controller.text);
        _controller.clear();
        _currentStep++;
      }
    });
  }

  void _processInputs() {
    // Combine inputs to produce a single output
    final result = _inputs.join(' '); // Example: concatenate inputs
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Result'),
        content: Text(result),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sequential Input Example'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                labelText: 'Input ${_currentStep + 1}',
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: _nextInput,
                  child: Text('Next Input'),
                ),
                ElevatedButton(
                  onPressed: _inputs.isNotEmpty ? _processInputs : null,
                  child: Text('Submit All'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
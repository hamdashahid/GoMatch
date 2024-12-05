import 'package:flutter/material.dart';

class SuggestionTextField extends StatelessWidget {
  final List<String> suggestions = [
    'ABC-1234',
    'XYZ-5678',
    'DEF-9012',
    'LMN-3456',
  ]; // Hardcoded suggestions

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Suggestion Text Field')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Autocomplete<String>(
          optionsBuilder: (TextEditingValue textEditingValue) {
            if (textEditingValue.text.isEmpty) {
              return const Iterable<String>.empty();
            }
            return suggestions.where((String option) {
              return option
                  .toLowerCase()
                  .contains(textEditingValue.text.toLowerCase());
            });
          },
          onSelected: (String selection) {
            print('You just selected $selection');
          },
          fieldViewBuilder: (BuildContext context,
              TextEditingController textEditingController,
              FocusNode focusNode,
              VoidCallback onFieldSubmitted) {
            return TextFormField(
              controller: textEditingController,
              focusNode: focusNode,
              decoration: InputDecoration(
                hintText: 'Enter vehicle number',
                labelText: 'Vehicle Number',
                border: OutlineInputBorder(),
              ),
            );
          },
        ),
      ),
    );
  }
}

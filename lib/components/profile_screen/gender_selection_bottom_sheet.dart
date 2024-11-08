import 'package:flutter/material.dart';
import 'package:gomatch/utils/colors.dart';

class GenderSelectionBottomSheet extends StatefulWidget {
  final String? selectedGender;
  final Function(String) onGenderSelected;

  const GenderSelectionBottomSheet({
    Key? key,
    required this.selectedGender,
    required this.onGenderSelected,
  }) : super(key: key);

  @override
  _GenderSelectionBottomSheetState createState() =>
      _GenderSelectionBottomSheetState();
}

class _GenderSelectionBottomSheetState
    extends State<GenderSelectionBottomSheet> {
  String? _selectedGender;

  @override
  void initState() {
    super.initState();
    _selectedGender = widget.selectedGender;
  }

  @override
Widget build(BuildContext context) {
  return Theme(
    data: Theme.of(context).copyWith(
      unselectedWidgetColor: Colors.white, // Change unselected radio button color
    ),
    child: Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Your gender',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 10),
          RadioListTile<String>(
            value: 'Female',
            groupValue: _selectedGender,
            title: const Text('Female', style: TextStyle(color: Colors.white)),
            activeColor: AppColors.secondaryColor, // Active radio button color
            onChanged: (value) {
              setState(() {
                _selectedGender = value;
              });
            },
          ),
          RadioListTile<String>(
            value: 'Male',
            groupValue: _selectedGender,
            title: const Text('Male', style: TextStyle(color: Colors.white)),
            activeColor: AppColors.secondaryColor,
            onChanged: (value) {
              setState(() {
                _selectedGender = value;
              });
            },
          ),
          RadioListTile<String>(
            value: 'Prefer not to specify',
            groupValue: _selectedGender,
            title: const Text('Prefer not to specify', style: TextStyle(color: Colors.white)),
            activeColor: AppColors.secondaryColor,
            onChanged: (value) {
              setState(() {
                _selectedGender = value;
              });
            },
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              widget.onGenderSelected(_selectedGender!);
              Navigator.pop(context); // Close the bottom sheet
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.secondaryColor,
              minimumSize: const Size(double.infinity, 50), // Full-width button
              foregroundColor: Colors.black,
            ),
            child: const Text('Update'),
          ),
        ],
      ),
    ),
  );
}

}

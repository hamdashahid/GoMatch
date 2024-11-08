import 'package:flutter/material.dart';
import 'package:gomatch/utils/colors.dart';

class DOBSelectionBottomSheet extends StatefulWidget {
  final DateTime? currentDOB;
  final Function(DateTime) onDOBSelected;

  const DOBSelectionBottomSheet({
    super.key,
    required this.currentDOB,
    required this.onDOBSelected,
  });

  @override
  // ignore: library_private_types_in_public_api
  _DOBSelectionBottomSheetState createState() => _DOBSelectionBottomSheetState();
}

class _DOBSelectionBottomSheetState extends State<DOBSelectionBottomSheet> {
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.currentDOB ?? DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Select Date of Birth',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold,color:Colors.white),
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: () async {
              DateTime? picked = await showDatePicker(
                context: context,
                initialDate: _selectedDate,
                firstDate: DateTime(1900),
                lastDate: DateTime.now(),
                builder: (BuildContext context, Widget? child) {
                  return Theme(
                    data: ThemeData.light().copyWith(
                      primaryColor: AppColors.primaryColor, // Toolbar color
                      colorScheme: const ColorScheme.light(
                        primary: AppColors.primaryColor, // Color for the selected date circle
                        onPrimary: Colors.white, // Text color in the selected date circle
                        secondary: Colors.white, // Text color for the button
                      ),
                    ),
                    child: child ?? const SizedBox(),
                  );
                },
              );
              if (picked != null) {
                setState(() {
                  _selectedDate = picked;
                });
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
            ),
            child: const Text('Pick Date'),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              widget.onDOBSelected(_selectedDate);
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.secondaryColor,
              minimumSize: const Size(double.infinity, 50),
              foregroundColor: Colors.black,
            ),
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }
}

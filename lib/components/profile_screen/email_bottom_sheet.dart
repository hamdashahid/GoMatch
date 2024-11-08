import 'package:flutter/material.dart';
import 'package:gomatch/utils/colors.dart';

class EmailBottomSheet extends StatefulWidget {
  final String? currentEmail;
  final Function(String) onEmailSelected;
  final Color emailTextColor;

  const EmailBottomSheet({
    super.key,
    required this.currentEmail,
    required this.onEmailSelected,
    this.emailTextColor = Colors.white,
  });

  @override
  // ignore: library_private_types_in_public_api
  _EmailBottomSheetState createState() => _EmailBottomSheetState();
}

class _EmailBottomSheetState extends State<EmailBottomSheet> {
  late TextEditingController _emailController;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController(text: widget.currentEmail);
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.all(20.0),
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           const Text('Update Email', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold,color:Colors.white)),
//           TextField(
//             controller: _emailController,
//             keyboardType: TextInputType.emailAddress,
//             decoration: const InputDecoration(labelText: 'Email',labelStyle:TextStyle(color:Colors.white),),
//             style: const TextStyle(color: Colors.white),
//           ),
//           const SizedBox(height: 20),
//           ElevatedButton(
//             onPressed: () {
//               widget.onEmailSelected(_emailController.text);
//               Navigator.pop(context);
//             },
//             style: ElevatedButton.styleFrom(
//               backgroundColor: AppColors.secondaryColor,
//               minimumSize: const Size(double.infinity, 50),
//               foregroundColor: Colors.black,
//             ),
//             child: const Text('Update'),
//           ),
//         ],
//       ),
//     );
//   }
// }
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Update Email',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white)),
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Email',
                labelStyle: TextStyle(color: Colors.white),
              ),
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                widget.onEmailSelected(_emailController.text);
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
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:frontend/core/constants/colors.dart';
import 'edit_letter_type_popup.dart';

class ViewLetterTypePopup extends StatelessWidget {
  const ViewLetterTypePopup({super.key});

  @override
  Widget build(BuildContext context) {
    final List<String> letterTypes = [
      "Doctor's Note",
      "Permission Letter",
      "Business Trip Letter",
    ];

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "View Letter Types",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: letterTypes.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    leading: const Icon(Icons.mail_outline),
                    title: Text(letterTypes[index]),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit,
                              color: AppColors.primaryYellow),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) {
                                return const EditLetterTypePopup(
                                  initialName: "Doctor's Note",
                                  initialContent:
                                      "This is to certify that the bearer is under my care.",
                                );
                              },
                            );
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete,
                              color: AppColors.primaryRed),
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content:
                                      Text("Delete ${letterTypes[index]}")),
                            );
                          },
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.bottomRight,
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Close"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:frontend/core/constants/colors.dart';

class EditPage extends StatelessWidget {
  const EditPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.pureWhite,
        foregroundColor: AppColors.black,
        title: const Text(
          "Edit Information Profile",
          style: TextStyle(color: AppColors.black),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile picture box
            Center(
              child: Stack(
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A355E),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.person,
                      size: 50,
                      color: AppColors.pureWhite,
                    ),
                  ),
                  Positioned(
                    bottom: 4,
                    right: 4,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: AppColors.pureWhite,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Icon(
                        Icons.edit,
                        color: Color(0xFF1A355E),
                        size: 18,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // --- Existing fields ---
            const _InputLabel("First Name"),
            const _TextField(hint: "Enter the First Name"),
            const SizedBox(height: 16),

            const _InputLabel("Mobile Number"),
            const _TextField(hint: "Enter the Mobile Number"),
            const SizedBox(height: 16),

            const _InputLabel("Gender"),
            _DropdownField(
              hint: "-Choose Gender",
              items: const ["Male", "Female"],
            ),
            const SizedBox(height: 16),

            const _InputLabel("Place of Birth"),
            const _TextField(hint: "Enter the Place of Birth"),
            const SizedBox(height: 16),

            const _InputLabel("Position"),
            const _TextField(hint: "Enter the Position"),
            const SizedBox(height: 16),

            const _InputLabel("Contract Type"),
            _DropdownField(
              hint: "-Choose Type",
              items: const ["Full Time", "Part Time", "Internship"],
            ),
            const SizedBox(height: 16),

            const _InputLabel("Bank"),
            _DropdownField(
              hint: "-Choose Bank",
              items: const ["BCA", "BRI", "Mandiri", "BNI"],
            ),
            const SizedBox(height: 16),

            const _InputLabel("Account Holder’s Name"),
            const _TextField(hint: "Bank Number Account Holder Name"),
            const SizedBox(height: 16),

            // --- Tambahan dari screenshot baru ---
            const _InputLabel("Last Name"),
            const _TextField(hint: "Enter the Last Name"),
            const SizedBox(height: 16),

            const _InputLabel("NIK"),
            const _TextField(hint: "Enter the NIK"),
            const SizedBox(height: 16),

            const _InputLabel("Last Education"),
            _DropdownField(
              hint: "-Choose Education",
              items: const ["SMA", "D3", "S1", "S2"],
            ),
            const SizedBox(height: 16),

            const _InputLabel("Date of Birth"),
            TextField(
              decoration: InputDecoration(
                hintText: "dd/mm/yyyy",
                prefixIcon: const Icon(Icons.calendar_today),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 14,
                ),
              ),
            ),
            const SizedBox(height: 16),

            const _InputLabel("Devision"),
            const _TextField(hint: "Enter the Devision"),
            const SizedBox(height: 16),

            const _InputLabel("Account Number"),
            const _TextField(hint: "Enter the Account Number"),
            const SizedBox(height: 16),

            const _InputLabel("Warning Letter Type"),
            _DropdownField(
              hint: "-Choose Type",
              items: const ["SP1", "SP2", "SP3"],
            ),
            const SizedBox(height: 30),

            // --- Tombol Save & Cancel ---
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    foregroundColor: AppColors.pureWhite,
                    backgroundColor: AppColors.primaryRed,
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text("Cancel"),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    foregroundColor: AppColors.pureWhite,
                    backgroundColor: AppColors.primaryGreen,
                  ),
                  onPressed: () {
                    // save action
                  },
                  child: const Text("Save"),
                ),
                const SizedBox(width: 12),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _InputLabel extends StatelessWidget {
  final String text;
  const _InputLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: AppColors.black,
      ),
    );
  }
}

class _TextField extends StatelessWidget {
  final String hint;
  const _TextField({required this.hint});

  @override
  Widget build(BuildContext context) {
    return TextField(
      decoration: InputDecoration(
        hintText: hint,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 14,
        ),
      ),
    );
  }
}

class _DropdownField extends StatelessWidget {
  final String hint;
  final List<String> items;

  const _DropdownField({required this.hint, required this.items});

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 14,
        ),
      ),
      hint: Text(hint),
      items: items
          .map((e) => DropdownMenuItem(value: e, child: Text(e)))
          .toList(),
      onChanged: (_) {},
    );
  }
}

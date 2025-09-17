import 'package:flutter/material.dart';

class AddEmployeePage extends StatefulWidget {
  const AddEmployeePage({super.key});

  @override
  State<AddEmployeePage> createState() => _AddEmployeePageState();
}

class _AddEmployeePageState extends State<AddEmployeePage> {
  // Controllers
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController mobileController = TextEditingController();
  final TextEditingController placeOfBirthController = TextEditingController();
  final TextEditingController positionController = TextEditingController();
  final TextEditingController nikController = TextEditingController();
  final TextEditingController accountHolderController = TextEditingController();
  final TextEditingController accountNumberController = TextEditingController();
  final TextEditingController divisionController = TextEditingController();

  // Dropdown values
  String? selectedGender;
  String? selectedContractType;
  String? selectedBank;
  String? selectedEducation;
  String? selectedWarningLetter;

  // Date of Birth
  DateTime? selectedDate;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add New Employee"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Upload Foto
            Row(
              children: [
                Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    color: Colors.blueGrey[900],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.person, color: Colors.white, size: 40),
                ),
                const SizedBox(width: 16),
                ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.add, color: Colors.white),
                  label: const Text("Upload Foto"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // First Name
            _buildTextField("First Name", "Enter the First Name", firstNameController),

            // Mobile Number
            _buildTextField("Mobile Number", "Enter the Mobile Number", mobileController, keyboard: TextInputType.phone),

            // Gender
            _buildDropdown("Gender", ["Male", "Female"], selectedGender, (value) {
              setState(() => selectedGender = value);
            }),

            // Place of Birth
            _buildTextField("Place of Birth", "Enter the Place of Birth", placeOfBirthController),

            // Position
            _buildTextField("Position", "Enter the Position", positionController),

            // Contract Type
            _buildDropdown("Contract Type", ["3 Months", "6 Months", "1 Year"], selectedContractType, (value) {
              setState(() => selectedContractType = value);
            }),

            // Bank
            _buildDropdown("Bank", ["BCA", "BRI", "Mandiri", "BNI"], selectedBank, (value) {
              setState(() => selectedBank = value);
            }),

            // Account Holder’s Name
            _buildTextField("Account Holder’s Name", "Bank Number Account Holder Name", accountHolderController),

            // Last Name
            _buildTextField("Last Name", "Enter the Last Name", lastNameController),

            // NIK
            _buildTextField("NIK", "Enter the NIK", nikController, keyboard: TextInputType.number),

            // Last Education
            _buildDropdown("Last Education", ["High School", "Diploma", "Bachelor", "Master"], selectedEducation, (value) {
              setState(() => selectedEducation = value);
            }),

            // Date of Birth
            _buildDatePicker(),

            // Division
            _buildTextField("Devision", "Enter the Devision", divisionController),

            // Account Number
            _buildTextField("Account Number", "Enter the Account Number", accountNumberController, keyboard: TextInputType.number),

            // Warning Letter Type
            _buildDropdown("Warning Letter Type", ["SP1", "SP2", "SP3"], selectedWarningLetter, (value) {
              setState(() => selectedWarningLetter = value);
            }),

            const SizedBox(height: 24),

            // Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                  ),
                  child: const Text("Cancel", style: TextStyle(color: Colors.white)),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: () {
                    // TODO: Save logic
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                  child: const Text("Save", style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, String hint, TextEditingController controller, {TextInputType keyboard = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        keyboardType: keyboard,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  Widget _buildDropdown(String label, List<String> items, String? value, Function(String?) onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: DropdownButtonFormField<String>(
        value: value,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        items: items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildDatePicker() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        readOnly: true,
        decoration: InputDecoration(
          labelText: "Date of Birth",
          hintText: "dd/mm/yyyy",
          border: const OutlineInputBorder(),
          suffixIcon: const Icon(Icons.calendar_today),
        ),
        onTap: () async {
          DateTime? pickedDate = await showDatePicker(
            context: context,
            initialDate: DateTime(2000),
            firstDate: DateTime(1950),
            lastDate: DateTime.now(),
          );
          if (pickedDate != null) {
            setState(() {
              selectedDate = pickedDate;
            });
          }
        },
        controller: TextEditingController(
          text: selectedDate != null
              ? "${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}"
              : "",
        ),
      ),
    );
  }
}

// ignore_for_file: deprecated_member_use

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:frontend/core/constants/colors.dart';
import 'package:intl/intl.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class AttendanceFormPage extends StatefulWidget {
  const AttendanceFormPage({super.key});

  @override
  State<AttendanceFormPage> createState() => _AttendanceFormPageState();
}

class _AttendanceFormPageState extends State<AttendanceFormPage> {
  String? selectedEmployee;
  String? absentType;
  String? location;

  DateTime? startDate;
  DateTime? endDate;

  final dateFormat = DateFormat('dd/MM/yy');
  final timeFormat = DateFormat('HH : mm : ss');

  String currentTime = "";

  // Controllers untuk field
  final TextEditingController addressController =
      TextEditingController(text: "");
  final TextEditingController latController = TextEditingController();
  final TextEditingController longController = TextEditingController();

  @override
  void initState() {
    super.initState();
    currentTime = timeFormat.format(DateTime.now());

    // Timer update jam
    Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        currentTime = timeFormat.format(DateTime.now());
      });
    });
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Cek apakah GPS aktif
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("⚠️ GPS tidak aktif, aktifkan dulu")),
      );
      return;
    }

    // Cek permission
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("⚠️ Izin lokasi ditolak")),
        );
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("⚠️ Izin lokasi ditolak permanen")),
      );
      return;
    }

    // Ambil lokasi sekarang
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    setState(() {
      latController.text = position.latitude.toString();
      longController.text = position.longitude.toString();
    });

    // Ambil alamat dari lat long
    List<Placemark> placemarks = await placemarkFromCoordinates(
      position.latitude,
      position.longitude,
    );

    if (placemarks.isNotEmpty) {
      Placemark place = placemarks.first;
      setState(() {
        addressController.text =
            "${place.street}, ${place.subLocality}, ${place.locality}, ${place.administrativeArea}";
      });
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("✅ Lokasi berhasil diambil")),
    );
  }

  void _saveForm() {
    if (selectedEmployee == null ||
        absentType == null ||
        startDate == null ||
        endDate == null ||
        location == null ||
        addressController.text.isEmpty ||
        latController.text.isEmpty ||
        longController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("⚠️ Semua field harus diisi!"),
          backgroundColor: AppColors.errorRed,
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("✅ Data berhasil disimpan"),
        backgroundColor: AppColors.primaryGreen,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    String lat = latController.text;
    String long = longController.text;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Attendance Form"),
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
            // Time
            const Text("Time"),
            const SizedBox(height: 5),
            TextFormField(
              readOnly: true,
              initialValue: currentTime,
              key: ValueKey(currentTime),
              decoration: const InputDecoration(border: OutlineInputBorder()),
            ),
            const SizedBox(height: 16),

            // Employee Name
            const Text("Employee Name"),
            const SizedBox(height: 5),
            DropdownButtonFormField<String>(
              value: selectedEmployee,
              items: ["Employee 1", "Employee 2"]
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (val) => setState(() => selectedEmployee = val),
              decoration: const InputDecoration(border: OutlineInputBorder()),
            ),
            const SizedBox(height: 16),

            // Absent Type
            const Text("Choose Absent Type"),
            const SizedBox(height: 5),
            DropdownButtonFormField<String>(
              value: absentType,
              items: [
                "Clock In",
                "Clock Out",
                "Absent",
                "Annual Leave",
                "Sick Leave",
              ].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
              onChanged: (val) => setState(() => absentType = val),
              decoration: const InputDecoration(border: OutlineInputBorder()),
            ),
            const SizedBox(height: 16),

            // Start & End Date
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    readOnly: true,
                    decoration: const InputDecoration(
                      labelText: "Start Date",
                      hintText: "dd/mm/yy",
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.calendar_today),
                    ),
                    controller: TextEditingController(
                      text: startDate != null
                          ? dateFormat.format(startDate!)
                          : "",
                    ),
                    onTap: () async {
                      DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );
                      if (pickedDate != null) {
                        setState(() => startDate = pickedDate);
                      }
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextFormField(
                    readOnly: true,
                    decoration: const InputDecoration(
                      labelText: "End Date",
                      hintText: "dd/mm/yy",
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.calendar_today),
                    ),
                    controller: TextEditingController(
                      text: endDate != null ? dateFormat.format(endDate!) : "",
                    ),
                    onTap: () async {
                      DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );
                      if (pickedDate != null) {
                        setState(() => endDate = pickedDate);
                      }
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Upload Supporting Evidence
            const Text("Upload Supporting Evidence"),
            const SizedBox(height: 5),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade400),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  const Icon(Icons.image_outlined,
                      size: 40, color: AppColors.black),
                  const SizedBox(height: 8),
                  const Text("Drag and Drop Here",
                      style: TextStyle(color: AppColors.black)),
                  const Text("Or", style: TextStyle(color: AppColors.black)),
                  GestureDetector(
                    onTap: () {},
                    child: const Text(
                      "Browse",
                      style: TextStyle(
                          color: AppColors.lightBlue,
                          decoration: TextDecoration.underline),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Location
            const Text("Location"),
            const SizedBox(height: 5),
            DropdownButtonFormField<String>(
              value: location,
              hint: const Text("Choose Location"),
              items: ["Office", "Home", "Other"]
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (val) => setState(() => location = val),
              decoration: const InputDecoration(border: OutlineInputBorder()),
            ),
            const SizedBox(height: 16),

            // Map Preview (pakai static map)
            if (lat.isNotEmpty && long.isNotEmpty)
              Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade400),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Image.network(
                  "https://maps.googleapis.com/maps/api/staticmap?center=$lat,$long&zoom=15&size=600x300&markers=color:red%7C$lat,$long&key=YOUR_GOOGLE_MAPS_API_KEY",
                  fit: BoxFit.cover,
                ),
              ),
            if (lat.isNotEmpty && long.isNotEmpty) const SizedBox(height: 16),

            // Detail Address (otomatis isi dari geocoding)
            TextFormField(
              controller: addressController,
              decoration: const InputDecoration(
                labelText: "Detail Address",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // Lat & Long + Button
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: latController,
                    decoration: const InputDecoration(
                      labelText: "Lat lokasi",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextFormField(
                    controller: longController,
                    decoration: const InputDecoration(
                      labelText: "Long lokasi",
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton.icon(
                onPressed: _getCurrentLocation,
                icon: const Icon(Icons.my_location),
                label: const Text("Get Current Location"),
              ),
            ),
            const SizedBox(height: 24),

            // Cancel & Save Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 30, vertical: 14),
                  ),
                  child: const Text("Cancel"),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: _saveForm,
                  style: ElevatedButton.styleFrom(
                    foregroundColor: AppColors.pureWhite,
                    backgroundColor: AppColors.primaryGreen,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 40, vertical: 14),
                  ),
                  child: const Text("Save"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

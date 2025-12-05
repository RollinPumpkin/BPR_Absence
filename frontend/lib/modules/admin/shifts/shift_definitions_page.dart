import 'package:flutter/material.dart';
import 'package:frontend/core/constants/colors.dart';
import 'package:frontend/data/services/shift_service.dart';

class ShiftDefinitionsPage extends StatefulWidget {
  const ShiftDefinitionsPage({super.key});

  @override
  State<ShiftDefinitionsPage> createState() => _ShiftDefinitionsPageState();
}

class _ShiftDefinitionsPageState extends State<ShiftDefinitionsPage> {
  final ShiftService _shiftService = ShiftService();
  List<Map<String, dynamic>> _shifts = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadShifts();
  }

  Future<void> _loadShifts() async {
    setState(() => _isLoading = true);
    
    try {
      final response = await _shiftService.getShiftDefinitions();
      
      if (response.success && response.data != null) {
        setState(() {
          _shifts = List<Map<String, dynamic>>.from(response.data ?? []);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading shifts: $e'),
          backgroundColor: AppColors.errorRed,
        ),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showEditDialog(Map<String, dynamic>? shift) {
    final isEdit = shift != null;
    
    final nameController = TextEditingController(text: shift?['name'] ?? '');
    final startTimeController = TextEditingController(text: shift?['start_time'] ?? '');
    final endTimeController = TextEditingController(text: shift?['end_time'] ?? '');
    final descriptionController = TextEditingController(text: shift?['description'] ?? '');
    
    Color selectedColor = shift != null 
        ? _parseColor(shift['color'] ?? '#FFA500')
        : Colors.orange;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(isEdit ? 'Edit Shift' : 'Add New Shift'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Shift Name',
                    hintText: 'e.g., Shift Pagi',
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: startTimeController,
                        readOnly: true,
                        decoration: const InputDecoration(
                          labelText: 'Start Time',
                          hintText: 'HH:mm',
                        ),
                        onTap: () async {
                          final time = await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay(
                              hour: int.tryParse(startTimeController.text.split(':').first) ?? 8,
                              minute: int.tryParse(startTimeController.text.split(':').last) ?? 0,
                            ),
                          );
                          if (time != null) {
                            startTimeController.text = 
                                '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        controller: endTimeController,
                        readOnly: true,
                        decoration: const InputDecoration(
                          labelText: 'End Time',
                          hintText: 'HH:mm',
                        ),
                        onTap: () async {
                          final time = await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay(
                              hour: int.tryParse(endTimeController.text.split(':').first) ?? 17,
                              minute: int.tryParse(endTimeController.text.split(':').last) ?? 0,
                            ),
                          );
                          if (time != null) {
                            endTimeController.text = 
                                '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
                          }
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    hintText: 'e.g., Morning shift for security',
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Text('Color: '),
                    const SizedBox(width: 8),
                    InkWell(
                      onTap: () async {
                        // Simple color picker
                        final colors = [
                          Colors.orange,
                          Colors.blue,
                          Colors.green,
                          Colors.red,
                          Colors.purple,
                          Colors.teal,
                          Colors.amber,
                          Colors.indigo,
                        ];
                        
                        final selected = await showDialog<Color>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Select Color'),
                            content: Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: colors.map((color) => InkWell(
                                onTap: () => Navigator.pop(context, color),
                                child: Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: color,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: selectedColor == color 
                                          ? Colors.black 
                                          : Colors.transparent,
                                      width: 2,
                                    ),
                                  ),
                                ),
                              )).toList(),
                            ),
                          ),
                        );
                        
                        if (selected != null) {
                          setDialogState(() {
                            selectedColor = selected;
                          });
                        }
                      },
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: selectedColor,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.grey),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                // Validate
                if (nameController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please enter shift name'),
                      backgroundColor: AppColors.primaryRed,
                    ),
                  );
                  return;
                }

                if (startTimeController.text.trim().isEmpty || 
                    endTimeController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please select start and end time'),
                      backgroundColor: AppColors.primaryRed,
                    ),
                  );
                  return;
                }

                Navigator.pop(context); // Close dialog

                // Show loading
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) => const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primaryGreen,
                    ),
                  ),
                );

                try {
                  // Save to API
                  final response = await _shiftService.saveShiftDefinition(
                    id: shift?['id'],
                    name: nameController.text.trim(),
                    startTime: startTimeController.text.trim(),
                    endTime: endTimeController.text.trim(),
                    color: '#${selectedColor.value.toRadixString(16).substring(2)}',
                    description: descriptionController.text.trim(),
                  );

                  Navigator.pop(context); // Close loading

                  if (response.success) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(isEdit 
                            ? 'Shift updated successfully' 
                            : 'Shift created successfully'),
                        backgroundColor: AppColors.primaryGreen,
                      ),
                    );
                    _loadShifts(); // Reload list
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Failed to save shift: ${response.message}'),
                        backgroundColor: AppColors.primaryRed,
                      ),
                    );
                  }
                } catch (e) {
                  Navigator.pop(context); // Close loading
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error: $e'),
                      backgroundColor: AppColors.primaryRed,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGreen,
                foregroundColor: AppColors.pureWhite,
              ),
              child: Text(isEdit ? 'Update' : 'Create'),
            ),
          ],
        ),
      ),
    );
  }

  Color _parseColor(String colorString) {
    try {
      final hex = colorString.replaceAll('#', '');
      return Color(int.parse('FF$hex', radix: 16));
    } catch (e) {
      return Colors.orange;
    }
  }

  String _colorToHex(Color color) {
    return '#${color.value.toRadixString(16).substring(2).toUpperCase()}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundGray,
      appBar: AppBar(
        title: const Text('Shift Definitions'),
        backgroundColor: AppColors.primaryGreen,
        foregroundColor: AppColors.pureWhite,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadShifts,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Info Card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blue.shade200),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.blue.shade700),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Define shift types that can be assigned to employees',
                            style: TextStyle(color: Colors.blue.shade700),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Shift List
                  ..._shifts.map((shift) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Dismissible(
                      key: Key(shift['id']),
                      direction: DismissDirection.endToStart,
                      confirmDismiss: (direction) async {
                        return await showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Delete Shift'),
                            content: Text('Are you sure you want to delete "${shift['name']}"?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: const Text('Cancel'),
                              ),
                              ElevatedButton(
                                onPressed: () => Navigator.pop(context, true),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primaryRed,
                                ),
                                child: const Text('Delete'),
                              ),
                            ],
                          ),
                        );
                      },
                      onDismissed: (direction) async {
                        try {
                          final response = await _shiftService.deleteShiftDefinition(shift['id']);
                          
                          if (response.success) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Shift deleted successfully'),
                                backgroundColor: AppColors.primaryGreen,
                              ),
                            );
                            _loadShifts();
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Failed to delete: ${response.message}'),
                                backgroundColor: AppColors.primaryRed,
                              ),
                            );
                            _loadShifts(); // Reload to restore
                          }
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Error: $e'),
                              backgroundColor: AppColors.primaryRed,
                            ),
                          );
                          _loadShifts(); // Reload to restore
                        }
                      },
                      background: Container(
                        decoration: BoxDecoration(
                          color: AppColors.primaryRed,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        child: const Icon(
                          Icons.delete,
                          color: AppColors.pureWhite,
                          size: 28,
                        ),
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.pureWhite,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(16),
                          leading: Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: _parseColor(shift['color'] ?? '#FFA500').withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.access_time,
                              color: _parseColor(shift['color'] ?? '#FFA500'),
                            ),
                          ),
                          title: Text(
                            shift['name'] ?? 'Unknown',
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Text(
                                '${shift['start_time']} - ${shift['end_time']}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.neutral800,
                                ),
                              ),
                              if (shift['description'] != null && shift['description'].toString().isNotEmpty) ...[
                                const SizedBox(height: 4),
                                Text(
                                  shift['description'],
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ],
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.edit, color: AppColors.primaryGreen),
                            onPressed: () => _showEditDialog(shift),
                          ),
                        ),
                      ),
                    ),
                  )),
                  
                  if (_shifts.isEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          children: [
                            Icon(Icons.access_time, size: 64, color: Colors.grey.shade300),
                            const SizedBox(height: 16),
                            Text(
                              'No shift definitions found',
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showEditDialog(null),
        backgroundColor: AppColors.primaryGreen,
        foregroundColor: AppColors.pureWhite,
        icon: const Icon(Icons.add),
        label: const Text('Add Shift'),
      ),
    );
  }
}

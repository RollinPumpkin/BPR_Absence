import 'package:flutter/material.dart';
import 'package:frontend/core/constants/colors.dart';

class DetailAssignmentPage extends StatelessWidget {
  const DetailAssignmentPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundGray,
      appBar: AppBar(
        backgroundColor: AppColors.pureWhite,
        elevation: 0,
        foregroundColor: AppColors.neutral800,
        title: const Text(
          'Detail Assignment',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            color: AppColors.neutral800,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionTitle('Nama Kegiatan'),
            const SizedBox(height: 6),
            _buildReadonlyBox(
              'Muncak Rinjani Ikut Lorenzo',
              maxLines: 2,
            ),
            const SizedBox(height: 16),

            _sectionTitle('Tags'),
            const SizedBox(height: 6),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: const [
                _TagChip('Tugas Buku'),
                _TagChip('Report'),
                _TagChip('Seminar'),
                _TagChip('Pelaporan OJK'),
                _TagChip('Audit'),
                _TagChip('Training / Pelatihan'),
                _TagChip('Monitoring & Pengkajian'),
              ],
            ),
            const SizedBox(height: 16),

            _sectionTitle('Description'),
            const SizedBox(height: 6),
            _buildReadonlyBox(
              'Muncak bersama bunga agam dan lorenzo membawa 3 ayam 2 bebek ...',
              maxLines: 4,
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: _buildReadonlyBox(
                    '27/08/2025',
                    label: 'Start Date',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildReadonlyBox(
                    'End Date',
                    label: 'End Date',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            _sectionTitle('Jam'),
            const SizedBox(height: 6),
            _buildReadonlyBox('17:45:00'),
            const SizedBox(height: 16),

            _sectionTitle('Link (Optional)'),
            const SizedBox(height: 6),
            _buildReadonlyBox('https://wordpress.anjay'),
            const SizedBox(height: 16),

            _sectionTitle('Employee Assignment'),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.pureWhite,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.dividerGray),
                boxShadow: const [
                  BoxShadow(
                    color: AppColors.shadowColor,
                    blurRadius: 12,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const CircleAvatar(
                    backgroundColor: AppColors.primaryBlue,
                    child: Icon(Icons.person, color: AppColors.pureWhite),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: _KV(
                      label: 'Septa Puma',
                      value: 'Manager',
                      boldLabel: true,
                    ),
                  ),
                  const _StatusPill(text: 'Active', color: AppColors.primaryGreen),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------- Helpers (kecil & reusable) ----------

  Widget _sectionTitle(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontWeight: FontWeight.w800,
        fontSize: 14.5,
        color: AppColors.neutral800,
      ),
    );
    }

  /// Read-only box. Kalau [label] diisi, label ditampilkan di atas box.
  Widget _buildReadonlyBox(
    String value, {
    int maxLines = 1,
    String? label,
  }) {
    final box = Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.pureWhite,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.dividerGray),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadowColor,
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Text(
        value,
        maxLines: maxLines,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(
          fontSize: 14,
          color: AppColors.neutral800,
          fontWeight: FontWeight.w600,
          height: 1.4,
        ),
      ),
    );

    if (label == null) return box;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.neutral500,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 6),
        box,
      ],
    );
  }
}

// ---------- Tiny widgets ----------

class _TagChip extends StatelessWidget {
  final String text;
  const _TagChip(this.text);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.neutral100,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.dividerGray),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 12,
          color: AppColors.neutral800,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _KV extends StatelessWidget {
  final String label;
  final String value;
  final bool boldLabel;
  const _KV({required this.label, required this.value, this.boldLabel = false});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 14,
            color: AppColors.neutral800,
            fontWeight: boldLabel ? FontWeight.w800 : FontWeight.w600,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.neutral500,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _StatusPill extends StatelessWidget {
  final String text;
  final Color color;
  const _StatusPill({required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(.35)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w800,
          fontSize: 12,
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../widgets/category_chips.dart';

class StartStageSheet extends StatefulWidget {
  final bool isBn;

  const StartStageSheet({super.key, required this.isBn});

  static void show({required bool isBn}) {
    Get.bottomSheet(
      StartStageSheet(isBn: isBn),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      ignoreSafeArea: false,
    );
  }

  @override
  State<StartStageSheet> createState() => _StartStageSheetState();
}

class _StartStageSheetState extends State<StartStageSheet> {
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  String _selectedCategory = 'general';
  String? _titleError;
  String? _descError;

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  void _validateAndStart() {
    final title = _titleController.text.trim();
    final desc = _descController.text.trim();

    setState(() {
      _titleError = title.isEmpty ? (widget.isBn ? 'এই ফিল্ডটি পূরণ করুন' : 'Please fill out this field.') : null;
      _descError = desc.isEmpty ? (widget.isBn ? 'এই ফিল্ডটি পূরণ করুন' : 'Please fill out this field.') : null;
    });

    if (_titleError != null || _descError != null) return;

    Get.back();
    Get.toNamed('/community/stage-room', arguments: {
      'title': title,
      'description': desc,
      'category': _selectedCategory,
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = true;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.9,
      ),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0a2f3d) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    const Icon(Icons.radio, color: Color(0xFFd97757), size: 28),
                    const SizedBox(width: 10),
                    Text(
                      widget.isBn ? 'স্টেজ শুরু করুন' : 'Start Stage',
                      style: GoogleFonts.notoSansBengali(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () => Get.back(),
                      child: const Icon(Icons.close, color: Colors.white, size: 24),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFF052029),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Text(
                    widget.isBn
                        ? 'আপনি একজন হোস্ট হিসাবে স্টেজ শুরু করবেন এবং অন্যরা আপনার সাথে যুক্ত হতে পারবে।'
                        : 'You will start the stage as a host and others can join you.',
                    style: GoogleFonts.notoSansBengali(
                      fontSize: 14,
                      color: const Color(0xFFB8DED6).withValues(alpha: 0.9),
                      height: 1.5,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                _buildLabel(widget.isBn ? 'স্টেজের শিরোনাম' : 'Stage Title'),
                const SizedBox(height: 8),
                _buildInput(
                  controller: _titleController,
                  hint: widget.isBn ? 'উদাহরণ: আজকের খবরের আলোচনা' : 'e.g. Today\'s News Discussion',
                  error: _titleError,
                  maxLines: 1,
                ),
                if (_titleError != null) ...[
                  const SizedBox(height: 6),
                  _buildError(_titleError!),
                ],
                const SizedBox(height: 16),
                _buildLabel(widget.isBn ? 'বিবরণ' : 'Description'),
                const SizedBox(height: 8),
                _buildInput(
                  controller: _descController,
                  hint: widget.isBn ? 'এই স্টেজটি সম্পর্কে কিছু লিখুন...' : 'Write something about this stage...',
                  error: _descError,
                  maxLines: 4,
                ),
                if (_descError != null) ...[
                  const SizedBox(height: 6),
                  _buildError(_descError!),
                ],
                const SizedBox(height: 16),
                _buildLabel(widget.isBn ? 'বিভাগ' : 'Category'),
                const SizedBox(height: 10),
                CategoryChips(
                  selected: _selectedCategory,
                  isBn: widget.isBn,
                  onSelected: (v) => setState(() => _selectedCategory = v),
                ),
                const SizedBox(height: 28),
                Row(
                  children: [
                    Expanded(
                      child: _buildCancelButton(),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStartButton(),
                    ),
                  ],
                ),
                SizedBox(height: MediaQuery.of(context).padding.bottom + 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: GoogleFonts.notoSansBengali(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
    );
  }

  Widget _buildInput({
    required TextEditingController controller,
    required String hint,
    required String? error,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      style: GoogleFonts.notoSansBengali(fontSize: 15, color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.notoSansBengali(color: const Color(0xFFB8DED6).withValues(alpha: 0.5)),
        filled: true,
        fillColor: const Color(0xFF0d3a4a),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: error != null ? Colors.red : const Color(0xFF0d3a4a)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: error != null ? Colors.red : const Color(0xFF0d3a4a)),
        ),
      ),
    );
  }

  Widget _buildError(String msg) {
    return Row(
      children: [
        Icon(Icons.error_outline, size: 18, color: Colors.orange.shade300),
        const SizedBox(width: 6),
        Text(
          msg,
          style: GoogleFonts.notoSansBengali(fontSize: 12, color: Colors.orange.shade300),
        ),
      ],
    );
  }

  Widget _buildCancelButton() {
    return GestureDetector(
      onTap: () => Get.back(),
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          color: const Color(0xFF0d3a4a),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Center(
          child: Text(
            widget.isBn ? 'বাতিল' : 'Cancel',
            style: GoogleFonts.notoSansBengali(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStartButton() {
    return GestureDetector(
      onTap: _validateAndStart,
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          color: const Color(0xFFd97757),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.radio, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Text(
              widget.isBn ? 'শুরু করুন' : 'Start',
              style: GoogleFonts.notoSansBengali(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

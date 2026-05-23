import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kitab_mandi/features/help_center/controller/help_support_controller.dart';
import 'package:kitab_mandi/widgets/app_text_field.dart';

class RaiseTicketView extends StatelessWidget {
  RaiseTicketView({super.key});
  final controller = Get.find<HelpSupportController>();
  Color _background(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? const Color(0xFF1A1D23) : const Color(0xFFFFFFFF);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Support"),
        centerTitle: true,
        elevation: 0,
        backgroundColor: _background(context),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// ================= HEADER =================
            _header(isDark),

            const SizedBox(height: 20),

            /// ================= CATEGORY =================
            _sectionTitle("Select Category"),
            const SizedBox(height: 8),
            Obx(
              () => Wrap(
                spacing: 8,
                runSpacing: 8,
                children: controller.categories.map((cat) {
                  final isSelected = controller.selectedCategory.value == cat;

                  return ChoiceChip(
                    label: Text(cat),
                    selected: isSelected,
                    onSelected: (_) => controller.selectedCategory.value = cat,
                    selectedColor: Colors.blue,
                    checkmarkColor: Colors.white,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : null,
                    ),
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 20),

            /// ================= PRIORITY =================
            _sectionTitle("Priority"),
            const SizedBox(height: 8),

            Obx(
              () => Wrap(
                spacing: 8,
                children: controller.priorities.map((p) {
                  final isSelected = controller.selectedPriority.value == p;

                  return ChoiceChip(
                    label: Text(p),
                    selected: isSelected,
                    onSelected: (_) => controller.selectedPriority.value = p,
                    selectedColor: _priorityColor(p),
                    checkmarkColor: Colors.white,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : null,
                    ),
                  );
                }).toList(),
              ),
            ),

            const SizedBox(height: 20),

            /// ================= TITLE =================
            _sectionTitle("Title"),
            const SizedBox(height: 8),
            _inputField(
              controller: controller.titleCtrl,
              hint: "Enter ticket title",
              isDark: isDark,
            ),

            const SizedBox(height: 16),

            /// ================= DESCRIPTION =================
            _sectionTitle("Description"),
            const SizedBox(height: 8),
            _inputField(
              controller: controller.descCtrl,
              hint: "Explain your issue clearly...",
              maxLines: 5,
              isDark: isDark,
            ),

            const SizedBox(height: 30),

            /// ================= SUBMIT =================
            Obx(
              () => SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: controller.isLoading.value
                      ? null // 🔥 disable button while loading
                      : controller.submitTicket,
                  child: controller.isLoading.value
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          "Submit Ticket",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                ),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  /// ================= HEADER =================
  Widget _header(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [Colors.blueGrey.shade800, Colors.black87]
              : [Colors.blue, Colors.lightBlueAccent],
        ),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: const [
          Icon(Icons.support_agent, color: Colors.white, size: 40),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Need Help?",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  "Our support team will respond quickly",
                  style: TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// ================= INPUT FIELD =================
  Widget _inputField({
    required TextEditingController controller,
    required String hint,
    required bool isDark,
    int maxLines = 1,
  }) {
    return AppTextField(
      controller: controller,
      hintText: hint,
      maxLines: maxLines,
      // filled: true,
      // fillColor: isDark ? const Color(0xFF1E1E1E) : Colors.grey.shade100,
      // borderRadius: 14,
    );
  }

  /// ================= SECTION TITLE =================
  Widget _sectionTitle(String text) {
    return Text(
      text,
      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
    );
  }

  /// ================= PRIORITY COLOR =================
  Color _priorityColor(String p) {
    switch (p) {
      case "High":
        return Colors.red;
      case "Medium":
        return Colors.orange;
      default:
        return Colors.green;
    }
  }
}

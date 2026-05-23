import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kitab_mandi/core/constants/app_color.dart';
import 'package:kitab_mandi/features/help_center/controller/help_support_controller.dart';
import 'package:kitab_mandi/features/help_center/view/raise_ticket_view.dart';
import 'package:kitab_mandi/widgets/app_button.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';

class HelpSupportView extends StatelessWidget {
  HelpSupportView({super.key});

  final controller = Get.put(HelpSupportController());

  Color _background(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? const Color(0xFF1A1D23) : const Color(0xFFFFFFFF);
  }

  Color _bg(BuildContext context) => Theme.of(context).scaffoldBackgroundColor;

  Color _card(BuildContext context) => Theme.of(context).cardColor;

  Color _textPrimary(BuildContext context) =>
      Theme.of(context).textTheme.bodyLarge!.color!;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg(context),
      appBar: AppBar(
        title: const Text("Help & Support"),
        centerTitle: true,
        elevation: 0,
        backgroundColor: _background(context),
      ),

      body: Obx(() {
        if (controller.isLoading.value) {
          return const HelpSupportShimmer();
        }

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _header(context),

            const SizedBox(height: 18),

            _sectionTitle("Contact Us", context),

            _contactCard(
              context,
              icon: Icons.chat_bubble_outline,
              title: "WhatsApp Support",
              subtitle: "Chat instantly with support",
              color: Colors.green,
              onTap: () {
                launchUrl(Uri.parse("https://wa.me/916306937005"));
              },
            ),

            _contactCard(
              context,
              icon: Icons.email_outlined,
              title: "Email Support",
              subtitle: "examsolvingofficial@gmail.com",
              color: Colors.blue,
              onTap: () {
                launchUrl(
                  Uri.parse(
                    "mailto:examsolvingofficial@gmail.com?subject=Help Needed",
                  ),
                );
              },
            ),

            _contactCard(
              context,
              icon: Icons.call_outlined,
              title: "Call Support",
              subtitle: "+91 6306937005",
              color: Colors.orange,
              onTap: () {
                launchUrl(Uri.parse("tel:+916306937005"));
              },
            ),

            const SizedBox(height: 20),

            _sectionTitle("Frequently Asked Questions", context),
            const SizedBox(height: 10),

            ...controller.faqs.map((faq) {
              return _FaqTile(
                question: faq['question'] ?? '',
                answer: faq['answer'] ?? '',
              );
            }),

            const SizedBox(height: 25),

            _raiseTicketCard(context),

            const SizedBox(height: 20),

            _sectionTitle("My Tickets", context),

            const SizedBox(height: 10),

            Obx(() {
              if (controller.userTickets.isEmpty) {
                return _emptyTickets(context);
              }

              return Column(
                children: controller.userTickets.map((ticket) {
                  return _ticketCard(context, ticket);
                }).toList(),
              );
            }),
          ],
        );
      }),
    );
  }

  // ================= HEADER =================
  Widget _header(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6A5AE0), Color(0xFF4A90E2)],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Row(
        children: [
          Icon(Icons.support_agent, color: Colors.white, size: 40),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              "We are here to help you 24x7",
              style: TextStyle(color: Colors.white, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  // ================= SECTION TITLE =================
  Widget _sectionTitle(String title, BuildContext context) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: _textPrimary(context),
      ),
    );
  }

  // ================= CONTACT CARD =================
  Widget _contactCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(top: 10),
      decoration: BoxDecoration(
        color: _card(context),
        borderRadius: BorderRadius.circular(14),
      ),
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.15),
          child: Icon(icon, color: color),
        ),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
      ),
    );
  }

  // ================= TICKET =================
  Widget _ticketCard(BuildContext context, Map<String, dynamic> ticket) {
    final status = ticket['status'] ?? 'open';

    Color color = status == 'resolved'
        ? Colors.green
        : status == 'in_progress'
        ? Colors.orange
        : Colors.red;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _card(context),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: color.withOpacity(0.15),
            child: Icon(Icons.support_agent, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ticket['title'] ?? '',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                Text(
                  ticket['category'] ?? '',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              status.toUpperCase(),
              style: TextStyle(
                color: color,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ================= EMPTY =================
  Widget _emptyTickets(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Column(
        children: [
          Icon(Icons.inbox_outlined, size: 50, color: Colors.grey),
          const SizedBox(height: 8),
          Text(
            "No tickets yet",
            style: TextStyle(color: _textPrimary(context)),
          ),
        ],
      ),
    );
  }

  // ================= RAISE TICKET =================
  Widget _raiseTicketCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF8E2DE2), Color(0xFF4A00E0)],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Need More Help?",
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
          const SizedBox(height: 6),
          const Text(
            "Raise a ticket and we will respond quickly.",
            style: TextStyle(color: Colors.white70),
          ),
          const SizedBox(height: 12),
          AppButton(
            backgroundColor: AppColors.darkPrimaryDark,
            text: "Raise Ticket",
            onPressed: () => Get.to(() => RaiseTicketView()),
          ),
        ],
      ),
    );
  }
}

// ================= FAQ TILE =================
class _FaqTile extends StatefulWidget {
  final String question;
  final String answer;

  const _FaqTile({required this.question, required this.answer});

  @override
  State<_FaqTile> createState() => _FaqTileState();
}

class _FaqTileState extends State<_FaqTile> {
  bool expanded = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(14),
      ),
      child: InkWell(
        onTap: () => setState(() => expanded = !expanded),
        child: Column(
          children: [
            Row(
              children: [
                const Icon(Icons.help_outline, color: Colors.blue),
                const SizedBox(width: 10),
                Expanded(child: Text(widget.question)),
                Icon(
                  expanded
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                ),
              ],
            ),
            if (expanded)
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Text(
                  widget.answer,
                  style: const TextStyle(color: Colors.grey),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ================= SHIMMER =================
class HelpSupportShimmer extends StatelessWidget {
  const HelpSupportShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: List.generate(
        8,
        (index) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Shimmer.fromColors(
            baseColor: Colors.grey.shade300,
            highlightColor: Colors.grey.shade100,
            child: Container(
              height: 60,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

abstract class IHelpRepository {
  Future<Map<String, dynamic>> loadConfig();
  Future<List<Map<String, dynamic>>> fetchFaqs();
  Future<List<Map<String, dynamic>>> fetchUserTickets(String userId);
  Future<void> submitTicket({
    required String userId,
    required String userEmail,
    required Map<String, dynamic> data,
  });
  Future<void> updateTicketStatus(String ticketId, String status);
  Future<void> deleteTicket(String ticketId);
}

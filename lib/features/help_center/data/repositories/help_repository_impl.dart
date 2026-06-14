import 'package:kitab_mandi/features/help_center/data/datasources/help_remote_datasource.dart';
import 'package:kitab_mandi/features/help_center/domain/repositories/i_help_repository.dart';

class HelpRepositoryImpl implements IHelpRepository {
  final HelpRemoteDataSource _ds;
  const HelpRepositoryImpl(this._ds);

  @override
  Future<Map<String, dynamic>> loadConfig() => _ds.loadConfig();

  @override
  Future<List<Map<String, dynamic>>> fetchFaqs() => _ds.fetchFaqs();

  @override
  Future<List<Map<String, dynamic>>> fetchUserTickets(String userId) =>
      _ds.fetchUserTickets(userId);

  @override
  Future<void> submitTicket({
    required String userId,
    required String userEmail,
    required Map<String, dynamic> data,
  }) =>
      _ds.submitTicket(userId: userId, userEmail: userEmail, data: data);

  @override
  Future<void> updateTicketStatus(String ticketId, String status) =>
      _ds.updateTicketStatus(ticketId, status);

  @override
  Future<void> deleteTicket(String ticketId) => _ds.deleteTicket(ticketId);
}

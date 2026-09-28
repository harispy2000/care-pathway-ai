import '../config/api_config.dart';
import '../core/api_client.dart';
import '../models/api_analysis_history_item.dart';
import '../models/care_pathway_response.dart';
import 'auth_service.dart';

class AnalysisHistoryApiService {
  final ApiClient _apiClient = ApiClient();

  Future<List<ApiAnalysisHistoryItem>> getHistory() async {
    final userId = await AuthService.getCurrentUserId();
    final data = await _apiClient.getList(ApiConfig.historyUrl(userId: userId));
    return data.map((item) => ApiAnalysisHistoryItem.fromJson(item)).toList();
  }

  Future<CarePathwayResponse> getHistoryById(int id) async {
    final userId = await AuthService.getCurrentUserId();
    final data = await _apiClient.getJson(ApiConfig.historyByIdUrl(id: id, userId: userId));
    return CarePathwayResponse.fromJson(data);
  }
}

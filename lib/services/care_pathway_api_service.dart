import '../config/api_config.dart';
import '../core/api_client.dart';
import '../models/care_pathway_request.dart';
import '../models/care_pathway_response.dart';

class CarePathwayApiService {
  final ApiClient _apiClient = ApiClient();

  Future<CarePathwayResponse> analyze(CarePathwayRequest request) async {
    final data = await _apiClient.postJson(ApiConfig.analyzeUrl, request.toJson());
    return CarePathwayResponse.fromJson(data);
  }
}

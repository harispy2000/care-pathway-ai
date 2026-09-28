using CarePathwayApi.Models;

namespace CarePathwayApi.Services;

public interface ICarePathwayService
{
    Task<CarePathwayResponse> AnalyzeAsync(CarePathwayRequest request, CancellationToken cancellationToken);
}

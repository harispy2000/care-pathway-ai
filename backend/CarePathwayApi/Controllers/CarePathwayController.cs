using CarePathwayApi.Data;
using CarePathwayApi.Entities;
using CarePathwayApi.Models;
using CarePathwayApi.Services;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Logging;

namespace CarePathwayApi.Controllers;

[ApiController]
[Route("api/care-pathway")]
public class CarePathwayController : ControllerBase
{
    private readonly CarePathwayService _ruleService;
    private readonly ICarePathwayService _aiService;
    private readonly AppDbContext _db;
    private readonly ILogger<CarePathwayController> _logger;

    public CarePathwayController(
        CarePathwayService ruleService,
        ICarePathwayService aiService,
        AppDbContext db,
        ILogger<CarePathwayController> logger)
    {
        _ruleService = ruleService;
        _aiService = aiService;
        _db = db;
        _logger = logger;
    }

    [HttpPost("analyze")]
    public async Task<IActionResult> Analyze(CarePathwayRequest request, CancellationToken cancellationToken)
    {
        if (request.Age <= 0)
        {
            return BadRequest("Age is required.");
        }

        if (string.IsNullOrWhiteSpace(request.Symptoms))
        {
            return BadRequest("Symptoms are required.");
        }

        var ruleResult = _ruleService.Analyze(request);

        CarePathwayResponse finalResult;

        // If rules detect an emergency, do not wait for AI.
        if (ruleResult.RiskScore >= 80 || ruleResult.TriageLevel.Contains("Emergency", StringComparison.OrdinalIgnoreCase))
        {
            finalResult = ruleResult;
            _logger.LogInformation("FALLBACK USED: YES (emergency rule path)");
        }
        else
        {
            try
            {
                finalResult = await _aiService.AnalyzeAsync(request, cancellationToken);
                finalResult = ApplySafetyGate(ruleResult, finalResult);
                _logger.LogInformation("FALLBACK USED: NO");
            }
            catch (Exception ex)
            {
                _logger.LogWarning("FALLBACK USED: YES (AI call failed: {Message})", ex.Message);
                finalResult = ruleResult;
            }
        }

        await SaveAnalysisAsync(request, finalResult, cancellationToken);

        return Ok(finalResult);
    }

    [HttpGet("history")]
    public async Task<IActionResult> GetHistory([FromQuery] int? userId)
    {
        var query = _db.AnalysisRecords.AsQueryable();

        if (userId.HasValue)
        {
            query = query.Where(x => x.UserId == userId.Value);
        }

        var history = await query
            .OrderByDescending(x => x.CreatedAt)
            .Select(x => new AnalysisHistoryItemResponse
            {
                Id = x.Id,
                UserId = x.UserId,
                Symptoms = x.Symptoms,
                TriageLevel = x.TriageLevel,
                RiskScore = x.RiskScore,
                RecommendedAction = x.RecommendedAction,
                CreatedAt = x.CreatedAt
            })
            .ToListAsync();

        return Ok(history);
    }

    [HttpGet("history/{id:int}")]
    public async Task<IActionResult> GetHistoryById(int id, [FromQuery] int? userId)
    {
        var record = await _db.AnalysisRecords
            .Include(x => x.CareSteps)
            .Include(x => x.RedFlags)
            .Include(x => x.MatchedFactors)
            .FirstOrDefaultAsync(x => x.Id == id);

        if (record == null)
        {
            return NotFound();
        }

        if (userId.HasValue && record.UserId != userId.Value)
        {
            return Forbid();
        }

        var response = new CarePathwayResponse
        {
            TriageLevel = record.TriageLevel,
            RiskScore = record.RiskScore,
            PossibleCondition = record.PossibleCondition,
            RecommendedAction = record.RecommendedAction,
            SafetyAdvice = record.SafetyAdvice,
            CareSteps = record.CareSteps.Select(x => x.Step).ToList(),
            RedFlags = record.RedFlags.Select(x => x.RedFlag).ToList(),
            MatchedFactors = record.MatchedFactors.Select(x => x.Factor).ToList()
        };

        return Ok(response);
    }

    private static CarePathwayResponse ApplySafetyGate(CarePathwayResponse ruleResult, CarePathwayResponse aiResult)
    {
        if (ruleResult.RiskScore > aiResult.RiskScore)
        {
            aiResult.RiskScore = ruleResult.RiskScore;
            aiResult.TriageLevel = ruleResult.TriageLevel;
        }

        foreach (var flag in ruleResult.RedFlags)
        {
            if (!aiResult.RedFlags.Contains(flag))
            {
                aiResult.RedFlags.Add(flag);
            }
        }

        foreach (var factor in ruleResult.MatchedFactors)
        {
            if (!aiResult.MatchedFactors.Contains(factor))
            {
                aiResult.MatchedFactors.Add(factor);
            }
        }

        if (aiResult.RedFlags.Count > 0 && aiResult.RiskScore < 60)
        {
            aiResult.RiskScore = 60;
            aiResult.TriageLevel = "Urgent";
        }

        return aiResult;
    }

    private async Task SaveAnalysisAsync(CarePathwayRequest request, CarePathwayResponse response, CancellationToken cancellationToken)
    {
        var record = new AnalysisRecord
        {
            UserId = request.UserId,
            Age = request.Age,
            Gender = request.Gender,
            Symptoms = request.Symptoms,
            Duration = request.Duration,
            Severity = request.Severity,
            ExistingConditions = request.ExistingConditions,
            Medications = request.Medications,
            TriageLevel = response.TriageLevel,
            RiskScore = response.RiskScore,
            PossibleCondition = response.PossibleCondition,
            RecommendedAction = response.RecommendedAction,
            SafetyAdvice = response.SafetyAdvice,
            CareSteps = response.CareSteps.Select(x => new AnalysisCareStep { Step = x }).ToList(),
            RedFlags = response.RedFlags.Select(x => new AnalysisRedFlag { RedFlag = x }).ToList(),
            MatchedFactors = response.MatchedFactors.Select(x => new AnalysisMatchedFactor { Factor = x }).ToList()
        };

        _db.AnalysisRecords.Add(record);
        await _db.SaveChangesAsync(cancellationToken);
    }
}

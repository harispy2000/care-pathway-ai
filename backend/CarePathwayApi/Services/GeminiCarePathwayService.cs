using System.Text;
using System.Text.Json;
using CarePathwayApi.Models;
using Microsoft.Extensions.Logging;

namespace CarePathwayApi.Services;

public class GeminiCarePathwayService : ICarePathwayService
{
    private readonly HttpClient _httpClient;
    private readonly IConfiguration _configuration;
    private readonly ILogger<GeminiCarePathwayService> _logger;

    public GeminiCarePathwayService(
        HttpClient httpClient,
        IConfiguration configuration,
        ILogger<GeminiCarePathwayService> logger)
    {
        _httpClient = httpClient;
        _configuration = configuration;
        _logger = logger;
    }

    public async Task<CarePathwayResponse> AnalyzeAsync(CarePathwayRequest request, CancellationToken cancellationToken)
    {
        var apiKey = _configuration["AI__Gemini__ApiKey"];
        if (string.IsNullOrWhiteSpace(apiKey))
        {
            throw new InvalidOperationException("AI__Gemini__ApiKey is not configured.");
        }

        var model = _configuration["AI__Gemini__Model"] ?? "gemini-3.8-flash";
        var endpoint = _configuration["AI__Gemini__BaseUrl"]
            ?? "https://generativelanguage.googleapis.com/v1beta/models";

        _logger.LogInformation("CARE PATHWAY AI");
        _logger.LogInformation("Provider: Gemini");
        _logger.LogInformation("Model: {Model}", model);
        _logger.LogInformation("Request started: YES");
        _logger.LogInformation("User symptom input: length={Length}", request.Symptoms.Length);

        var prompt = $$"""
You are a controlled healthcare decision-support assistant.
Do not diagnose. Do not replace a doctor. This is NOT an emergency service.
Respond ONLY based on the symptoms supplied below. Do not invent patient information.
Return only valid JSON with these EXACT fields:
triageLevel, riskScore, possibleCondition, recommendedAction, safetyAdvice, matchedFactors, redFlags, careSteps.

Field rules:
- triageLevel: one of "Emergency", "Urgent", "Moderate", "Non Emergency"
- riskScore: integer 0-100
- possibleCondition: short description (not a diagnosis)
- recommendedAction: what the user should do next
- safetyAdvice: disclaimer and safety guidance
- matchedFactors: array of relevant factors from the input
- redFlags: array of urgent warning signs if any
- careSteps: array of practical conservative care steps

If symptoms may indicate an emergency, set triageLevel to "Emergency" and riskScore high (80+),
list the red flags, and recommend seeking emergency medical help immediately.

User details:
Age: {{request.Age}}
Gender: {{request.Gender}}
Symptoms: {{request.Symptoms}}
Duration: {{request.Duration}}
Severity: {{request.Severity}}
Existing conditions: {{request.ExistingConditions}}
Medications: {{request.Medications}}
""";

        var payload = new
        {
            contents = new[]
            {
                new { role = "user", parts = new[] { new { text = prompt } } }
            },
            generationConfig = new
            {
                temperature = 0.2,
                responseMimeType = "application/json",
                responseSchema = new
                {
                    type = "object",
                    properties = new
                    {
                        triageLevel = new { type = "string" },
                        riskScore = new { type = "integer" },
                        possibleCondition = new { type = "string" },
                        recommendedAction = new { type = "string" },
                        safetyAdvice = new { type = "string" },
                        matchedFactors = new { type = "array", items = new { type = "string" } },
                        redFlags = new { type = "array", items = new { type = "string" } },
                        careSteps = new { type = "array", items = new { type = "string" } }
                    },
                    required = new[] { "triageLevel", "riskScore", "possibleCondition", "recommendedAction", "safetyAdvice", "matchedFactors", "redFlags", "careSteps" }
                }
            }
        };

        var json = JsonSerializer.Serialize(payload);
        using var content = new StringContent(json, Encoding.UTF8, "application/json");

        var url = $"{endpoint}/{model}:generateContent?key={apiKey}";
        using var response = await _httpClient.PostAsync(url, content, cancellationToken);

        _logger.LogInformation("Gemini response received: {Status}", response.IsSuccessStatusCode ? "YES" : "NO");
        _logger.LogInformation("HTTP/API status: {StatusCode}", (int)response.StatusCode);

        var responseText = await response.Content.ReadAsStringAsync(cancellationToken);

        if (!response.IsSuccessStatusCode)
        {
            _logger.LogError("Gemini request failed with HTTP {StatusCode}: {Body}", (int)response.StatusCode, responseText);
            throw new InvalidOperationException($"Gemini returned HTTP {(int)response.StatusCode}.");
        }

        var aiContent = ExtractJson(responseText);
        _logger.LogInformation("AI RAW RESPONSE RECEIVED: {Received}", string.IsNullOrWhiteSpace(aiContent) ? "NO" : "YES");

        var options = new JsonSerializerOptions { PropertyNameCaseInsensitive = true };
        var result = JsonSerializer.Deserialize<CarePathwayResponse>(aiContent, options);

        _logger.LogInformation("Response parsed: {Parsed}", result != null ? "YES" : "NO");

        if (result == null)
        {
            throw new InvalidOperationException("Gemini returned unparseable JSON.");
        }

        result.RiskScore = Math.Clamp(result.RiskScore, 0, 100);
        result.MatchedFactors ??= [];
        result.RedFlags ??= [];
        result.CareSteps ??= [];

        return result;
    }

    private static string ExtractJson(string responseText)
    {
        using var doc = JsonDocument.Parse(responseText);
        var root = doc.RootElement;

        if (root.TryGetProperty("candidates", out var candidates) &&
            candidates.GetArrayLength() > 0)
        {
            var first = candidates[0];
            if (first.TryGetProperty("content", out var content) &&
                content.TryGetProperty("parts", out var parts) &&
                parts.GetArrayLength() > 0)
            {
                var text = parts[0].TryGetProperty("text", out var t) ? t.GetString() ?? "" : "";
                return CleanJson(text);
            }
        }

        if (root.TryGetProperty("error", out var error))
        {
            var msg = error.TryGetProperty("message", out var m) ? m.GetString() ?? "Unknown error" : "Unknown error";
            throw new InvalidOperationException($"Gemini API error: {msg}");
        }

        return CleanJson(responseText);
    }

    private static string CleanJson(string text)
    {
        text = text.Trim();
        if (text.StartsWith("```"))
        {
            text = text.Replace("```json", "", StringComparison.OrdinalIgnoreCase).Replace("```", "").Trim();
        }

        var start = text.IndexOf('{');
        var end = text.LastIndexOf('}');
        if (start >= 0 && end > start)
        {
            text = text[start..(end + 1)];
        }
        return text;
    }
}

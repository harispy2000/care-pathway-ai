using CarePathwayApi.Models;

namespace CarePathwayApi.Services;

public class CarePathwayService : ICarePathwayService
{
    public Task<CarePathwayResponse> AnalyzeAsync(CarePathwayRequest request, CancellationToken cancellationToken)
    {
        return Task.FromResult(Analyze(request));
    }

    public CarePathwayResponse Analyze(CarePathwayRequest request)
    {
        var symptoms = request.Symptoms.ToLowerInvariant();
        var severity = request.Severity.ToLowerInvariant();
        var matched = new List<string>();
        var redFlags = new List<string>();
        var risk = 20;

        if (severity.Contains("severe"))
        {
            risk += 25;
            matched.Add("Severe symptom level");
        }

        if (symptoms.Contains("chest pain") || symptoms.Contains("shortness of breath") || symptoms.Contains("difficulty breathing"))
        {
            risk += 50;
            redFlags.Add("Chest pain or breathing difficulty can be urgent.");
            matched.Add("Possible heart/breathing red flag");
        }

        if (symptoms.Contains("stroke") || symptoms.Contains("face droop") || symptoms.Contains("slurred speech") || symptoms.Contains("weakness one side"))
        {
            risk += 55;
            redFlags.Add("Stroke-like symptoms need emergency care.");
            matched.Add("Possible neurological red flag");
        }

        if (symptoms.Contains("unconscious") || symptoms.Contains("seizure") || symptoms.Contains("heavy bleeding"))
        {
            risk += 60;
            redFlags.Add("Loss of consciousness, seizure, or heavy bleeding needs urgent help.");
            matched.Add("Emergency red flag symptom");
        }

        risk = Math.Clamp(risk, 0, 100);

        var triage = risk >= 80 ? "Emergency" : risk >= 60 ? "Urgent" : risk >= 40 ? "Moderate" : "Non Emergency";

        return new CarePathwayResponse
        {
            TriageLevel = triage,
            RiskScore = risk,
            PossibleCondition = redFlags.Count > 0 ? "Possible urgent condition" : "General symptom concern",
            RecommendedAction = risk >= 80
                ? "Seek emergency medical help immediately."
                : risk >= 60
                    ? "Contact a doctor or urgent care soon."
                    : "Monitor symptoms and consult a doctor if symptoms worsen.",
            SafetyAdvice = "This is AI-assisted guidance only and not a medical diagnosis. If symptoms are severe or worsening, seek professional medical help.",
            MatchedFactors = matched,
            RedFlags = redFlags,
            CareSteps = risk >= 80
                ? ["Call emergency services or go to the nearest emergency department.", "Do not drive yourself if symptoms are severe.", "Keep emergency contact informed."]
                : ["Rest and monitor symptoms.", "Drink fluids if appropriate.", "Contact a doctor if symptoms persist or worsen."]
        };
    }
}

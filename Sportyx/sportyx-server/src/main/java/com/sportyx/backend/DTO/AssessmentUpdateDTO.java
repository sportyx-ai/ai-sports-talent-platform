package com.sportyx.backend.DTO;

import io.swagger.v3.oas.annotations.media.Schema;
import lombok.Data;
import java.math.BigDecimal;
import java.util.Map;

@Data
public class AssessmentUpdateDTO {
    @Schema(example = "8.5", description = "Overall score between 0.00 and 10.00")
    private BigDecimal overallScore;
    
    @Schema(example = "{\"speed\": 8.5, \"agility\": 7.2, \"stamina\": 6.0}", description = "Skill breakdown scores")
    private Map<String, Object> skillScores;
    
    @Schema(example = "TALENT", description = "Performance level classification")
    private String performanceLevel;
    
    @Schema(example = "Excellent speed and ball control. Shows great potential.", description = "Athlete's strengths")
    private String strengths;
    
    @Schema(example = "Needs to work on stamina and defensive positioning.", description = "Areas that need improvement")
    private String areasToImprove;
    
    @Schema(example = "Focus on endurance training and tactical awareness drills.", description = "Recommendations for improvement")
    private String recommendations;
}

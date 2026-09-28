package com.sportyx.backend.DTO;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.Data;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Data
@JsonIgnoreProperties(ignoreUnknown = true)
public class MlAnalysisResponseDTO {
    private String exercise;
    
    @JsonProperty("overall_score")
    private Double overallScore = 0.0;
    
    @JsonProperty("total_reps")
    private Integer totalReps = 0;
    
    @JsonProperty("valid_reps")
    private Integer validReps = 0;
    
    @JsonProperty("invalid_reps")
    private Integer invalidReps = 0;
    
    private Map<String, Object> subscores = new HashMap<>();
    private List<String> strengths = new ArrayList<>();
    private List<String> weaknesses = new ArrayList<>();
    private List<String> warnings = new ArrayList<>();
    private CheatingReportDTO cheating;

    @Data
    @JsonIgnoreProperties(ignoreUnknown = true)
    public static class CheatingReportDTO {
        private Boolean detected = false;
        private String reason = "";
        private String decision = "pass";
    }
}

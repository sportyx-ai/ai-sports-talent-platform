package com.sportyx.backend.config;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.servlet.config.annotation.ResourceHandlerRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;

import java.nio.file.Path;
import java.nio.file.Paths;

@Configuration
public class WebConfig implements WebMvcConfigurer {

    @Value("${app.upload.dir:uploads}")
    private String uploadDir;

    @Override
    public void addResourceHandlers(ResourceHandlerRegistry registry) {
        try {
            Path uploadPath = Paths.get(uploadDir).toAbsolutePath().normalize();
            String location = "file:" + uploadPath.toString().replace("\\", "/") + "/";

            // Serve all uploads
            registry.addResourceHandler("/uploads/**")
                .addResourceLocations(location)
                .setCachePeriod(0)  // No cache for dynamic content
                .resourceChain(true);

            // Specific handlers for different file types
            registry.addResourceHandler("/uploads/videos/**")
                .addResourceLocations(location)
                .setCachePeriod(86400);  // 1 day cache for videos

            registry.addResourceHandler("/uploads/athletes/**")
                .addResourceLocations(location)
                .setCachePeriod(86400);  // 1 day cache for photos
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}

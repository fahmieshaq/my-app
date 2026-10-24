package com.example.smoketest;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import java.util.Map;
@RestController
@RequestMapping("/api")
public class HelloController {
    private static final Logger log = LoggerFactory.getLogger(HelloController.class);
    @GetMapping("/hello")
    public Map<String,String> hello() {
        log.info("Smoke test endpoint invoked");
        return Map.of("message", "Spring Boot AWS blueprint smoke test");
    }
}

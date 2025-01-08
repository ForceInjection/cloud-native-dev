package io.daocloud.userservice;

import com.netflix.discovery.EurekaClient;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.annotation.Configuration;
import javax.annotation.PreDestroy;

@Configuration
public class EurekaShutdownConfig {

    @Autowired
    private EurekaClient eurekaClient;

    @PreDestroy
    public void onShutdown() {
        System.out.println("In shutdown hook");
        if (eurekaClient != null) {
            System.out.println("Shutting down Eureka client...");
            eurekaClient.shutdown();
        }
    }
}
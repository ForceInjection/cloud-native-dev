package io.daocloud.adminservice;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.cloud.client.discovery.EnableDiscoveryClient;
import org.springframework.cloud.netflix.ribbon.RibbonClient;
import org.springframework.cloud.openfeign.EnableFeignClients;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

import io.daocloud.adminservice.config.CustomRule;
import io.daocloud.adminservice.fegin.UserFeign;

@SpringBootApplication
@EnableFeignClients
@EnableDiscoveryClient
@RestController
@RibbonClient(name = "user-service", configuration = CustomRule.class)
public class AdminServiceApplication {

	public static void main(String[] args) {
		SpringApplication.run(AdminServiceApplication.class, args);
	}

	@Autowired
	private UserFeign userFeign;

	@GetMapping("/port")
	public Object port() {
		return userFeign.port();
	}

}

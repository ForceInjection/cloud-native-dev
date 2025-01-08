package io.daocloud.eurekaserver;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.cloud.netflix.eureka.server.EnableEurekaServer;

/**
 * Author: Grissom
 * Date: 2020/7/16 6:06 下午
 * Description: Eureka 服务注册中心主启动类。
 * 使用@SpringBootApplication注解标识为Spring Boot应用，
 * 使用@EnableEurekaServer注解启用Eureka服务注册中心功能。
 * 
 * 主要功能：
 * 1. 启动Eureka服务注册中心
 */
@SpringBootApplication
@EnableEurekaServer
public class EurekaServerApplication {

	public static void main(String[] args) {
		SpringApplication.run(EurekaServerApplication.class, args);
	}

}

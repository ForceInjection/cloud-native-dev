package io.daocloud.adminservice.config;

import com.netflix.client.config.IClientConfig;
import com.netflix.loadbalancer.AbstractLoadBalancerRule;
import com.netflix.loadbalancer.DynamicServerListLoadBalancer;
import com.netflix.loadbalancer.ILoadBalancer;
import com.netflix.loadbalancer.Server;

import org.springframework.context.annotation.Configuration;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.List;

/**
 * Author: Grissom
 * Date: 2020/7/16 5:32 下午
 * Description: 自定义负载均衡规则，用于实现轮询负载均衡
 */
@Configuration
public class CustomRule extends AbstractLoadBalancerRule {

    @Override
    public void initWithNiwsConfig(IClientConfig clientConfig) {

    }

    @Override
    public Server choose(Object key) {

        ILoadBalancer loadBalancer = getLoadBalancer();

        if (loadBalancer instanceof DynamicServerListLoadBalancer) {
            logWithTimestamp(Thread.currentThread().getName() + " - 更新服务器列表");
            ((DynamicServerListLoadBalancer<?>) loadBalancer).updateListOfServers();
        }

        // 获取所有可达服务器列表
        List<Server> servers = loadBalancer.getReachableServers();
        if (servers.isEmpty()) {
            return null;
        }

        // 打印所有可达服务器
        logWithTimestamp(Thread.currentThread().getName() + " - 所有可达服务器：" + servers);

        // Generate a random index and return that server
        int randomIndex = (int) (Math.random() * servers.size());
        logWithTimestamp(
                Thread.currentThread().getName() + " - Servers[" + randomIndex + "]: " + servers.get(randomIndex));

        return servers.get(randomIndex);
    }

    private void logWithTimestamp(String message) {
        String timestamp = LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss"));
        System.out.println("[" + timestamp + "] " + message);
    }

}

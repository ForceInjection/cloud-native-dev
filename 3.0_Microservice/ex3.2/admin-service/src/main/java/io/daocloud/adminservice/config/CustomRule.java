package io.daocloud.adminservice.config;

import com.netflix.client.config.IClientConfig;
import com.netflix.loadbalancer.AbstractLoadBalancerRule;
import com.netflix.loadbalancer.ILoadBalancer;
import com.netflix.loadbalancer.Server;

import org.springframework.context.annotation.Configuration;

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

        // 获取所有可达服务器列表
        List<Server> servers = loadBalancer.getReachableServers();
        if (servers.isEmpty()) {
            return null;
        }

        // Generate a random index and return that server
        int randomIndex = (int) (Math.random() * servers.size());
        System.out.println("随机索引：" + randomIndex);
        return servers.get(randomIndex);
    }

}

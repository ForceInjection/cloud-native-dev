package io.daocloud.adminservice.config;

import com.netflix.client.config.IClientConfig;
import com.netflix.loadbalancer.AbstractLoadBalancerRule;
import com.netflix.loadbalancer.ILoadBalancer;
import com.netflix.loadbalancer.IRule;
import com.netflix.loadbalancer.Server;
import io.daocloud.adminservice.service.UserService;import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

import java.util.List;

/**
 * Author: Garroshh
 * date: 2020/7/16 5:32 下午
 */
@Configuration
public class CustomRule extends AbstractLoadBalancerRule {

    @Override
    public void initWithNiwsConfig(IClientConfig clientConfig) {

    }

    @Override
    public Server choose(Object key) {

        ILoadBalancer loadBalancer = getLoadBalancer();

        //获取所有可达服务器列表
        List<Server> servers = loadBalancer.getReachableServers();
        if (servers.isEmpty()) {
            return null;
        }
        //UserService (5个实例 （up）)

        // 3 -> 1 -> 3 -> 1

//        int flag = false;
//        int count = 0;
//
//        for (int i=0; i<servers.size(); i++){
//            if (flag){
//                count ++;
//                if (count <= 3){
//
//                }
//                return servers.get(i);
//            }
//            if (i % 2 = 0){
//                count ++;
//                flag = true;
//                return servers.get(i);
//            }else{
//
//            }
//        }




        // 永远选择最后一台可达服务器
        Server targetServer = servers.get(servers.size() - 1);
        return targetServer;
    }

}

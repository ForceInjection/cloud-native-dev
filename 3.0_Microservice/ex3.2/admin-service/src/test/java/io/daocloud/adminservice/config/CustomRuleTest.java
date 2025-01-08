package io.daocloud.adminservice.config;

import com.netflix.loadbalancer.ILoadBalancer;
import com.netflix.loadbalancer.Server;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.boot.test.mock.mockito.MockBean;
import org.springframework.test.context.junit.jupiter.SpringExtension;
import org.junit.jupiter.api.extension.ExtendWith;

import java.util.Arrays;
import java.util.Collections;
import java.util.List;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.Mockito.*;

@SpringBootTest(classes = CustomRule.class)
@ExtendWith(SpringExtension.class)
class CustomRuleTest {

    @MockBean
    private ILoadBalancer loadBalancer;

    private CustomRule customRule;

    @BeforeEach
    void setUp() {
        customRule = new CustomRule();
        customRule.setLoadBalancer(loadBalancer);
    }

    @Test
    void testChooseWithAvailableServers() {
        // Arrange
        Server server1 = new Server("localhost", 8080);
        Server server2 = new Server("localhost", 8081);
        List<Server> servers = Arrays.asList(server1, server2);
        when(loadBalancer.getReachableServers()).thenReturn(servers);

        // Act
        Server chosenServer = customRule.choose(null);

        // Assert
        assertNotNull(chosenServer);
        assertTrue(servers.contains(chosenServer));
    }

    @Test
    void testChooseWithNoAvailableServers() {
        // Arrange
        when(loadBalancer.getReachableServers()).thenReturn(Collections.emptyList());

        // Act
        Server chosenServer = customRule.choose(null);

        // Assert
        assertNull(chosenServer);
    }

    @Test
    void testChooseReturnsRandomServer() {
        // Arrange
        Server server1 = new Server("localhost", 8080);
        Server server2 = new Server("localhost", 8081);
        Server server3 = new Server("localhost", 8082);
        List<Server> servers = Arrays.asList(server1, server2, server3);
        when(loadBalancer.getReachableServers()).thenReturn(servers);

        int[] serverCounts = new int[servers.size()];

        // Act - run multiple times to test randomness
        for (int i = 0; i < 1000; i++) {
            Server server = customRule.choose(null);
            int index = servers.indexOf(server);
            serverCounts[index]++;
        }

        // Assert - verify all servers were chosen at least once
        for (int count : serverCounts) {
            assertTrue(count > 0);
        }
    }
}
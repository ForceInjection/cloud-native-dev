package io.daocloud.adminservice.fegin;

import io.daocloud.adminservice.dto.UserDto;
import org.springframework.cloud.openfeign.FeignClient;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;

/**
 * Author: Garroshh
 * date: 2020/7/9 8:39 下午
 */
@FeignClient(name = "user-service")
public interface UserFeign {

    @PostMapping("/user")
    Object add(UserDto userDto);

    @GetMapping("/port")
    String port();
}

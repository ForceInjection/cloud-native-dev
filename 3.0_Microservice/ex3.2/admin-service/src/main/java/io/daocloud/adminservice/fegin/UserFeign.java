package io.daocloud.adminservice.fegin;

import org.springframework.cloud.openfeign.FeignClient;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestParam;

import io.daocloud.adminservice.dto.UserDto;

/**
 * Author: Grissom
 * Date: 2020/7/9 8:39 下午
 */
@FeignClient(name = "user-service")
public interface UserFeign {

    @PostMapping("/user")
    UserDto add(UserDto userDto);

    @GetMapping("/user")
    UserDto get(@RequestParam("id") long id);

    @GetMapping("/port")
    String port();
}

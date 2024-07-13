package io.daocloud.adminservice.controller;

import io.daocloud.adminservice.dto.UserDto;
import io.daocloud.adminservice.service.UserService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RestController;

import javax.validation.Valid;

/**
 * Author: Garroshh
 * date: 2020/7/9 8:42 下午
 */
@RestController
public class UserController {
    @Autowired
    private UserService userService;

    @PostMapping("/user")
    public Object add(@RequestBody @Valid UserDto userDto){
        return userService.add(userDto);
    }
}

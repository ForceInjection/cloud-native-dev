package io.daocloud.adminservice.controller;

import javax.validation.Valid;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.MediaType;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import io.daocloud.adminservice.dto.UserDto;
import io.daocloud.adminservice.service.UserService;

/**
 * Author: Grissom
 * Date: 2020/7/9 8:42 下午
 */
@RestController
public class UserController {
    @Autowired
    private UserService userService;

    @PostMapping("/user")
    public UserDto add(@RequestBody @Valid UserDto userDto){
        return userService.add(userDto);
    }

    @GetMapping(path = "/user", produces = MediaType.APPLICATION_JSON_VALUE)
    public UserDto get(@RequestParam("id") long id) {
        return userService.get(id);
    }
}

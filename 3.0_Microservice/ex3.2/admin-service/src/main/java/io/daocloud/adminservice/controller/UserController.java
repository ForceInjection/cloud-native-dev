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
 * Description: 用户管理控制器，提供用户相关的RESTful API接口。
 * 主要功能包括：
 * 1. 添加用户 - POST /user
 * 2. 查询用户 - GET /user?id={id}
 * 
 * 使用@RestController注解标识为REST控制器，
 * 所有方法返回值将自动转换为JSON格式。
 * 
 * 通过@Autowired注入UserService进行业务逻辑处理，
 * 使用@Valid注解进行请求参数校验。
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

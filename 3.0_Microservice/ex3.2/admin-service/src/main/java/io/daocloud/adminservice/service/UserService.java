package io.daocloud.adminservice.service;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import io.daocloud.adminservice.dto.UserDto;
import io.daocloud.adminservice.fegin.UserFeign;

/**
 * Author: Grissom
 * Date: 2020/7/9 8:38 下午
 */
@Component
public class UserService {
    @Autowired
    private UserFeign userFeign;

    public UserDto add(UserDto userDto){
        //远程http调用
        return userFeign.add(userDto);
    }

    public UserDto get(long id){
        //远程http调用
        return userFeign.get(id);
    }
}

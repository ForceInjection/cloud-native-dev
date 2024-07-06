package io.daocloud.adminservice.service;

import io.daocloud.adminservice.dto.UserDto;
import io.daocloud.adminservice.fegin.UserFeign;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

/**
 * Author: Garroshh
 * date: 2020/7/9 8:38 下午
 */
@Component
public class UserService {
    @Autowired
    private UserFeign userFeign;

    public Object add(UserDto userDto){
        //远程http调用
        return userFeign.add(userDto);
    }
}

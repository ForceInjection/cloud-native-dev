package io.daocloud.userservice.service;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import io.daocloud.userservice.dao.UserDao;
import io.daocloud.userservice.domain.User;

/**
 * Author: Grissom
 * Date: 2020/7/9 8:19 下午
 * Description: 用户服务业务逻辑实现类。
 * 
 * 主要功能：
 * 1. 用户信息新增
 * 2. 用户信息查询
 */
@Service
public class UserService {
	@Autowired
	private UserDao userDao;

	public User add(User user) {
		return userDao.save(user);
	}

	public User get(long id) {
		return userDao.getOne(id);
	}
}

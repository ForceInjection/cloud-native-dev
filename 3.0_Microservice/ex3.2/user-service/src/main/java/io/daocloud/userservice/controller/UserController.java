package io.daocloud.userservice.controller;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.server.ResponseStatusException;

import io.daocloud.userservice.domain.User;
import io.daocloud.userservice.domain.UserVO;
import io.daocloud.userservice.service.UserService;

/**
 * Author: Grissom
 * Date: 2020/7/9 8:24 下午
 * Description: 用户控制器，用于处理用户相关的HTTP请求
 */
@RestController
public class UserController {
	@Autowired
	private UserService userService;

	/**
	 * 新增用户
	 * 
	 * @param user 用户对象
	 * @return 新增的用户对象
	 */
	@PostMapping("/user")
	public User add(@RequestBody User user) {
		return userService.add(user);
	}

	/**
	 * 获取用户
	 * 
	 * @param id 用户ID
	 * @return 用户对象
	 */
	@GetMapping(path = "/user", produces = MediaType.APPLICATION_JSON_VALUE)
	public UserVO get(@RequestParam("id") long id) {
		try {
			User u = userService.get(id);
			return new UserVO(u.getId(), u.getName(), u.getPwd());
		} catch (RuntimeException e) {
			System.out.println("User with id " + id + " not found");
			// 返回 404 状态码和具体的错误信息。
			throw new ResponseStatusException(HttpStatus.NOT_FOUND, "User with id " + id + " not found", e);
		}
	}
}

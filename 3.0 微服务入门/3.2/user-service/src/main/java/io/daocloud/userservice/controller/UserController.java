package io.daocloud.userservice.controller;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.MediaType;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import io.daocloud.userservice.domain.User;
import io.daocloud.userservice.domain.UserVO;
import io.daocloud.userservice.service.UserService;

/**
 * Author: Grissom date: 2020/7/9 8:24 下午
 */
@RestController
public class UserController {
	@Autowired
	private UserService userService;

	@PostMapping("/user")
	public User add(@RequestBody User user) {
		return userService.add(user);
	}

	@GetMapping(path = "/user", produces = MediaType.APPLICATION_JSON_VALUE)
	public UserVO get(@RequestParam("id") long id) {
		User u = userService.get(id);
		return new UserVO(u.getId(), u.getName(), u.getPwd());
	}
}

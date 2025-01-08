package io.daocloud.userservice.dao;

import io.daocloud.userservice.domain.User;
import org.springframework.data.jpa.repository.JpaRepository;

/**
 * Author: Grissom
 * Date: 2020/7/9 8:18 下午
 * Description: 用户数据访问接口，用于访问用户数据
 * 
 */
public interface UserDao extends JpaRepository<User, Long> {
}
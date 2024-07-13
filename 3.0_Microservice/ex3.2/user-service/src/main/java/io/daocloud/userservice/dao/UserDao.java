package io.daocloud.userservice.dao;

import io.daocloud.userservice.domain.User;
import org.springframework.data.jpa.repository.JpaRepository;

/**
 * Author: Garroshh
 * date: 2020/7/9 8:18 下午
 */
public interface UserDao extends JpaRepository<User, Long> {
}

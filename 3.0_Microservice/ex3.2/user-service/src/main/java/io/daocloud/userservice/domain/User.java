package io.daocloud.userservice.domain;

import javax.persistence.*;

/**
 * Author: Grissom
 * Date: 2020/7/9 8:17 下午
 * Description: 用户实体类，用于表示用户信息。
 */
@Entity
@Table(name="user")
public class User {

    /**
     * 用户ID
     */
    @Id
    @GeneratedValue(strategy=GenerationType.AUTO)
    private Long id;

    /**
     * 用户名
     */
    @Column(length = 32)
    private String name;

    /**
     * 用户密码
     */
    @Column(length = 64)
    private String pwd;

    /**
     * 获取用户ID
     * @return 用户ID
     */
    public Long getId() {
        return id;
    }

    /**
     * 设置用户ID
     * @param id 用户ID
     */
    public void setId(Long id) {
        this.id = id;
    }

    /**
     * 获取用户名
     * @return 用户名
     */
    public String getName() {
        return name;
    }

    /**
     * 设置用户名
     * @param name 用户名
     */
    public void setName(String name) {
        this.name = name;
    }

    /**
     * 获取用户密码
     * @return 用户密码
     */
    public String getPwd() {
        return pwd;
    }

    /**
     * 设置用户密码
     * @param pwd 用户密码
     */
    public void setPwd(String pwd) {
        this.pwd = pwd;
    }
}

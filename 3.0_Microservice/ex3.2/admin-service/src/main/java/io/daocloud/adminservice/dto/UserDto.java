package io.daocloud.adminservice.dto;

import javax.validation.constraints.NotBlank;

/**
 * Author: Grissom
 * Date: 2020/7/9 8:39 下午
 * Description: 用户数据传输对象（DTO），用于在控制器层和服务层之间传递用户数据。
 * 包含用户的基本信息字段，使用JSR-303注解进行数据校验：
 * 1. @NotBlank - 确保用户名和密码不为空
 * 
 * 该DTO主要用于：
 * 1. 接收前端传入的用户注册/登录数据
 * 2. 作为服务层方法的参数对象
 * 3. 确保数据在传递过程中的完整性和有效性
 */
public class UserDto {
    @NotBlank(message = "用户名不能为空")
    private String name;

    @NotBlank(message = "密码不能为空")
    private String pwd;

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getPwd() {
        return pwd;
    }

    public void setPwd(String pwd) {
        this.pwd = pwd;
    }
}

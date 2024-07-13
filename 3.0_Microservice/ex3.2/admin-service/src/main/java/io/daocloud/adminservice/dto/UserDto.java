package io.daocloud.adminservice.dto;

import javax.validation.constraints.NotBlank;

/**
 * Author: Garroshh
 * date: 2020/7/9 8:39 下午
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

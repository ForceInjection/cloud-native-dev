/**
 * 
 */
package io.daocloud.userservice.domain;

/**
 * Author: Grissom
 * Date: 2020/7/9 8:17 下午
 * Description: 用户视图对象，用于表示用户信息，用于在客户端和服务端之间传递用户对象
 * 
 */
public class UserVO {

    /**
     * 用户ID
     */
	private Long id;

    /**
     * 用户名
     */
	private String name;

    /**
     * 用户密码
     */
	private String pwd;

    /**
     * 构造函数
     */
	public UserVO() {

	}

    /**
     * 构造函数
     * @param id 用户ID
     * @param name 用户名
     * @param pwd 用户密码
     */
	public UserVO(Long id, String name, String pwd) {
		this.id = id;
		this.name = name;
		this.pwd = pwd;
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

}

/**
 * 
 */
package io.daocloud.userservice.domain;

/**
 * @author Grissom
 *
 */
public class UserVO {
	private Long id;

	private String name;

	private String pwd;

	public UserVO() {

	}

	public UserVO(Long id, String name, String pwd) {
		this.id = id;
		this.name = name;
		this.pwd = pwd;
	}

	public String getPwd() {
		return pwd;
	}

	public void setPwd(String pwd) {
		this.pwd = pwd;
	}

	public String getName() {
		return name;
	}

	public void setName(String name) {
		this.name = name;
	}

	public Long getId() {
		return id;
	}

	public void setId(Long id) {
		this.id = id;
	}

}

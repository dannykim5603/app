package com.sbs.jhs.at.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@AllArgsConstructor
@NoArgsConstructor
@Data
@Getter
@Setter
public class Member {
	private int id;
	private String regDate;
	private String loginId;
	private String email;
	private String name;
	private String nickname;
	private String loginPw;
}

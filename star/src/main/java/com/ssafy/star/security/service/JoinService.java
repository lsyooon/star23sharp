package com.ssafy.star.security.service;

import com.ssafy.star.exception.CustomErrorCode;
import com.ssafy.star.exception.CustomException;
import com.ssafy.star.member.entity.Member;
import com.ssafy.star.member.repository.MemberRepository;
import com.ssafy.star.security.dto.JoinDTO;
import lombok.RequiredArgsConstructor;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;

@Service
@RequiredArgsConstructor
public class JoinService {

    private final MemberRepository memberRepository;

    private final PasswordEncoder passwordEncoder;


    public void joinProcess(JoinDTO joinDTO) {

        //db에 이미 동일한 유저 네임을 가진 회원이 존재하는지 검증
        if (checkMemberId(joinDTO.getMemberId())) {
            throw new CustomException(CustomErrorCode.MEMBER_ALREADY_EXISTS);
        }
        if (checkNickname(joinDTO.getNickname())) {
            throw new CustomException(CustomErrorCode.NICKNAME_ALREADY_EXISTS);
        }
        Member data = Member.builder()
                .memberName(joinDTO.getMemberId())
                .password(passwordEncoder.encode(joinDTO.getPassword()))
                .role("ROLE_USER")
                .nickname(joinDTO.getNickname())
                .complaintCount(0)
                .createdAt(LocalDateTime.now())
                .build();

        memberRepository.save(data);

    }

    public boolean checkMemberId(String memberId) {
        return memberRepository.existsByMemberName(memberId);
    }
    public boolean checkNickname(String nickname) {
        return memberRepository.existsByNickname(nickname);
    }

}

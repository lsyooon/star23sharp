package com.ssafy.star.member.service;

import com.ssafy.star.member.dto.response.MemberInfoResponse;
import com.ssafy.star.member.entity.Member;
import com.ssafy.star.member.repository.MemberRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class MemberService {

    private final MemberRepository memberRepository;


    public MemberInfoResponse findMemberInfo(Long memberId){

        Member member = memberRepository.findById(memberId).orElse(null);
        if(member == null){
            return null;
        }
        return MemberInfoResponse.builder()
                .memberId(member.getMemberName())
                .nickname(member.getNickname())
                .isPushNotificationEnabled(member.isPushNotificationEnabled())
                .build();
    }


}

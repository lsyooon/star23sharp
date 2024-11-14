package com.ssafy.star.member.service;

import com.ssafy.star.exception.CustomErrorCode;
import com.ssafy.star.exception.CustomException;
import com.ssafy.star.member.dto.request.NickBookRequest;
import com.ssafy.star.member.dto.response.NickBookResponse;
import com.ssafy.star.member.entity.Member;
import com.ssafy.star.member.entity.NickBook;
import com.ssafy.star.member.repository.MemberRepository;
import com.ssafy.star.member.repository.NickBookRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.stereotype.Service;

import java.util.ArrayList;
import java.util.List;

@Service
@RequiredArgsConstructor
public class NickBookService {

    private final NickBookRepository nickBookRepository;
    private final MemberRepository memberRepository;

    public List<NickBookResponse> getNicknameBookList(Long memberId) {
        List<NickBookResponse> result = nickBookRepository.findAllByMemberId(memberId);
        if (result == null) {
            return new ArrayList<>();
        }
        return result;
    }

    public NickBookResponse addNicknameToBook(Long memberId, NickBookRequest nickBookRequest) {
        Member member = memberRepository.findById(memberId).orElseThrow(
                () -> new CustomException(CustomErrorCode.MEMBER_NOT_FOUND));

        if(member.getNickname().equals(nickBookRequest.getNickname())) {
            throw new CustomException(CustomErrorCode.SELF_NICKBOOK_ADDITION_NOT_ALLOWED);
        }

        boolean existNickname = memberRepository.existsByNickname(nickBookRequest.getNickname());
        if (!existNickname) {
            throw new CustomException(CustomErrorCode.MEMBER_NOT_FOUND);
        }



        NickBook newNickBook = NickBook.builder()
                .member(member)
                .nickname(nickBookRequest.getNickname())
                .name(nickBookRequest.getName())
                .build();
        try {

        NickBook  nickBook = nickBookRepository.save(newNickBook);
        return new NickBookResponse(nickBook.getId(),nickBook.getNickname(),nickBook.getName());
        }catch (DataIntegrityViolationException e) {
            throw new CustomException(CustomErrorCode.NICKBOOK_ALREADY_EXISTS);
        }
    }

    public void updateNicknameToBook(Long memberId,Long nickBookId, NickBookRequest nickBookRequest) {
        boolean existNickname = memberRepository.existsByNickname(nickBookRequest.getNickname());
        if (!existNickname) {
            throw new CustomException(CustomErrorCode.MEMBER_NOT_FOUND);
        }

        NickBook nickBook = nickBookRepository.findById(nickBookId).orElseThrow(()->
                new CustomException(CustomErrorCode.NICKBOOK_NOT_FOUND));

        if (nickBook.getMember().getId() != memberId) {
            throw new CustomException(CustomErrorCode.UNAUTHORIZED_NICKBOOK_ACCESS);
        }

        nickBook.modifyNickNameAndName(nickBookRequest.getNickname(),nickBookRequest.getName());

        try {
            nickBookRepository.save(nickBook);
        }catch (DataIntegrityViolationException e) {
            throw new CustomException(CustomErrorCode.NICKBOOK_ALREADY_EXISTS);
        }
    }

    public void deleteNickBook(Long memberId, Long nickBookId) {

        NickBook nickBook = nickBookRepository.findById(nickBookId).orElseThrow(()->
                new CustomException(CustomErrorCode.NICKBOOK_NOT_FOUND));

        if(!nickBook.getMember().getId().equals(memberId)) {
            throw new CustomException(CustomErrorCode.UNAUTHORIZED_NICKBOOK_ACCESS);
        }

        nickBookRepository.delete(nickBook);

    }

    public NickBookResponse getNickBook(Long memberId, Long nickBookId) {
        NickBook nickBook = nickBookRepository.findById(nickBookId).orElseThrow(
                () -> new CustomException(CustomErrorCode.NICKBOOK_NOT_FOUND)
        );
        if(!nickBook.getMember().getId().equals(memberId)) {
            throw new CustomException(CustomErrorCode.UNAUTHORIZED_NICKBOOK_ACCESS);
        }
        NickBookResponse nickBookResponse = new NickBookResponse(nickBook.getId(), nickBook.getNickname(), nickBook.getName());

        return nickBookResponse;
    }

}

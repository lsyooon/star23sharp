package com.ssafy.star.member.repository;

import com.ssafy.star.member.dto.response.NickBookResponse;
import com.ssafy.star.member.entity.NickBook;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;

import java.util.List;

public interface NickBookRepository extends JpaRepository<NickBook, Long> {

    @Query("""
    SELECT new com.ssafy.star.member.dto.response.NickBookResponse(nb.id,nb.nickname,nb.name) 
    FROM NickBook nb WHERE nb.member.id = :memberId
    """)
    List<NickBookResponse> findAllByMemberId(Long memberId);

    boolean existsByNicknameAndMemberId(String nickname, Long memberId);

}

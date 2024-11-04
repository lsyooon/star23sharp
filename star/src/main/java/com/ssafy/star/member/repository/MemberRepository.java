package com.ssafy.star.member.repository;

import com.ssafy.star.member.entity.Member;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;

@Repository
public interface MemberRepository extends JpaRepository<Member, Long> {

    boolean existsByMemberName(String memberName);

    boolean existsByNickname(String nickname);

    Member findByMemberName(String memberName);

    @Query("SELECT m.id FROM Member m WHERE m.memberName = :memberName")
    Long findIdByMemberName(String memberName);

}

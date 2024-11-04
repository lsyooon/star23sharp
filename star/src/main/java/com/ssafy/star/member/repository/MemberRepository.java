package com.ssafy.star.member.repository;

import com.ssafy.star.member.entity.Member;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface MemberRepository extends JpaRepository<Member, Long> {

    boolean existsByMemberName(String memberName);

    Member findByMemberName(String memberName);

}

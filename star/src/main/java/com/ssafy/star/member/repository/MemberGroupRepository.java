package com.ssafy.star.member.repository;

import com.ssafy.star.member.entity.MemberGroup;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;

public interface MemberGroupRepository extends JpaRepository<MemberGroup, Long> {
    @Query("SELECT mg.groupName FROM MemberGroup mg WHERE mg.id = :id")
    String findGroupNameById(Long id);

    @Query("SELECT mg.isConstructed FROM MemberGroup mg WHERE mg.id = :id")
    Boolean findIsConstructedByGroupId(Long id);

    MemberGroup findMemberGroupById(Long id);
}

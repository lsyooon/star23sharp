package com.ssafy.star.member.repository;

import com.ssafy.star.member.entity.GroupMember;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;

import java.util.List;

public interface GroupMemberRepository extends JpaRepository<GroupMember, Long> {

    @Query("SELECT m.nickname FROM Member m " +
            "JOIN GroupMember gm ON gm.member.id = m.id " +
            "WHERE gm.group.id = :groupId")
    List<String> findNicknamesByGroupId(Long groupId);

    @Query("SELECT m.id FROM Member m " +
            "JOIN GroupMember gm ON gm.member.id = m.id " +
            "WHERE gm.group.id = :groupId")
    List<Long> findMemberIdsByGroupId(Long groupId);

}

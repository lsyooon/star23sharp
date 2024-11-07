package com.ssafy.star.message.repository;

import com.ssafy.star.member.entity.MemberGroup;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;

public interface GroupRepository extends JpaRepository<MemberGroup, Long> {

    @Query("SELECT mg.isConstructed FROM MemberGroup mg WHERE mg.id = :id")
    Boolean isConstructed(Long id);


    @Query("SELECT mg.groupName FROM MemberGroup mg WHERE mg.id = :id")
    String getConstructedGroupInfo(Long id);

    @Query("SELECT count(*) FROM GroupMember gm WHERE gm.group.id = :id")
    Long countConstructed(Long id);

    @Query(value = "SELECT m.nickname FROM group_member gm " +
            "JOIN member m ON m.id = gm.member_id " +
            "WHERE gm.group_id = :id " +
            "LIMIT 1", nativeQuery = true)
    String getFirstMemberNameInGroup(Long id);


}

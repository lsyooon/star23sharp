package com.ssafy.star.member.repository;

import com.ssafy.star.member.entity.Member;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;
import org.springframework.transaction.annotation.Transactional;

@Repository
public interface MemberRepository extends JpaRepository<Member, Long> {

    boolean existsByMemberName(String memberName);

    boolean existsByNickname(String nickname);

    Member findByMemberName(String memberName);

    @Query("SELECT m.id FROM Member m WHERE m.memberName = :memberName")
    Long findIdByMemberName(String memberName);

    @Query("SELECT m.id FROM Member m WHERE m.nickname = :nickname")
    Long findIdByNickname(String nickname);

    Member findMemberById(long id);

    @Query("SELECT m.memberName FROM Member m WHERE m.id = :id")
    String findMemberNameById(Long id);

    @Transactional
    @Modifying
    @Query("UPDATE Member m SET m.isPushNotificationEnabled = :isPushNotificationEnabled WHERE m.id = :id")
    void updatePushNotificationEnabledById(Long id, boolean isPushNotificationEnabled);

    @Query("SELECT m.nickname FROM Member m WHERE m.id = :id")
    String findNicknameById(Long id);
}

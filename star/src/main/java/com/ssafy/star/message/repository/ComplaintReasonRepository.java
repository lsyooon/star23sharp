package com.ssafy.star.message.repository;

import com.ssafy.star.message.dto.response.ComplaintReasonResponse;
import com.ssafy.star.message.entity.ComplaintReason;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface ComplaintReasonRepository extends JpaRepository<ComplaintReason, Short> {
    @Query("SELECT new com.ssafy.star.message.dto.response.ComplaintReasonResponse(c.id, c.complaintReason)" +
            "FROM ComplaintReason c")
    List<ComplaintReasonResponse> getAllComplaintReasons();
}

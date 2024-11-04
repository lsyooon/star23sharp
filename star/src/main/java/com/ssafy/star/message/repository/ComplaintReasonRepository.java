package com.ssafy.star.message.repository;

import com.ssafy.star.message.entity.ComplaintReason;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface ComplaintReasonRepository extends JpaRepository<ComplaintReason, Short> {
    ComplaintReason findComplaintReasonById(Short id);
}

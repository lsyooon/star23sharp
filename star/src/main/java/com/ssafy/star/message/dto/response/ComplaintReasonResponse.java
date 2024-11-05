package com.ssafy.star.message.dto.response;

import lombok.Getter;
import lombok.NoArgsConstructor;

@Getter
@NoArgsConstructor
public class ComplaintReasonResponse {
    private short complaintId;
    private String complaintReason;

    public ComplaintReasonResponse(short complaintId, String complaintReason) {
        this.complaintId = complaintId;
        this.complaintReason = complaintReason;
    }
}

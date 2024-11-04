package com.ssafy.star.security.controller;


import com.ssafy.star.security.dto.JoinDTO;
import com.ssafy.star.security.service.JoinService;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequiredArgsConstructor
@RequestMapping("/join")
public class JoinController {


    private final JoinService joinService;

    @PostMapping("")
    public String join(@RequestBody JoinDTO joinDTO) {

        joinService.joinProcess(joinDTO);

        return "ok";
    }



}

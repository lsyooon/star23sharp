package com.ssafy.star.security.service;

import com.ssafy.star.member.entity.Member;
import com.ssafy.star.member.repository.MemberRepository;
import com.ssafy.star.security.dto.CustomUserDetails;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.stereotype.Service;

@Service
@RequiredArgsConstructor
public class CustomUserDetailsService implements UserDetailsService {


    private final MemberRepository userRepository;

    @Override
    public UserDetails loadUserByUsername(String username) throws UsernameNotFoundException {

        Member userData = userRepository.findByMemberName(username);

        if (userData != null) {
            return new CustomUserDetails(userData);
        }
        throw new UsernameNotFoundException(username);
    }
}

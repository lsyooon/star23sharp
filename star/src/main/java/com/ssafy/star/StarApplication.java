package com.ssafy.star;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.scheduling.annotation.EnableAsync;

@SpringBootApplication
@EnableAsync
public class StarApplication {

	public static void main(String[] args) {
		SpringApplication.run(StarApplication.class, args);
	}

}

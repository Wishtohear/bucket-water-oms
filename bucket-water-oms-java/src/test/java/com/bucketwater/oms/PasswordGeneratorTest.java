package com.bucketwater.oms;

import org.junit.jupiter.api.Test;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;

public class PasswordGeneratorTest {

    @Test
    void generatePassword() {
        BCryptPasswordEncoder encoder = new BCryptPasswordEncoder();
        String password = "123456";
        String encoded = encoder.encode(password);
        System.out.println("========================================");
        System.out.println("Password: " + password);
        System.out.println("Encoded: " + encoded);
        System.out.println("========================================");
    }
}

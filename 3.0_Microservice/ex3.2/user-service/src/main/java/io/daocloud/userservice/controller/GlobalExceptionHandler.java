package io.daocloud.userservice.controller;

import java.time.LocalDateTime;
import java.util.LinkedHashMap;
import java.util.Map;
import java.util.Optional;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.ControllerAdvice;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.context.request.RequestContextHolder;
import org.springframework.web.context.request.ServletRequestAttributes;
import org.springframework.web.server.ResponseStatusException;

/*
 * Author: Grissom
 * Date: 2020/7/9 8:25 下午
 * Description: 全局异常处理类，用于统一处理Controller层抛出的异常
 * 
 * 主要功能：
 * 1. 处理ResponseStatusException异常
 * 2. 返回统一的错误响应格式，包含时间戳、状态码、错误信息和请求路径

 */
@ControllerAdvice
public class GlobalExceptionHandler {

    @ExceptionHandler(ResponseStatusException.class)
    public ResponseEntity<Map<String, Object>> handleResponseStatusException(ResponseStatusException ex) {
        Map<String, Object> body = new LinkedHashMap<>();
        body.put("timestamp", LocalDateTime.now());
        body.put("status", ex.getStatus().value());
        body.put("error", ex.getStatus().getReasonPhrase());
        body.put("message", ex.getReason()); // 确保 message 字段被正确设置
        body.put("path", Optional.ofNullable(RequestContextHolder.getRequestAttributes())
                .map(attrs -> ((ServletRequestAttributes) attrs).getRequest().getRequestURI())
                .orElse("unknown"));

        return new ResponseEntity<>(body, ex.getStatus());
    }
}
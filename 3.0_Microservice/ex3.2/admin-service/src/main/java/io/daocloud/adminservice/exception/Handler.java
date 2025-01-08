package io.daocloud.adminservice.exception;

import org.springframework.http.HttpStatus;
import org.springframework.web.bind.MethodArgumentNotValidException;
import org.springframework.web.bind.annotation.ControllerAdvice;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.bind.annotation.ResponseStatus;

import javax.servlet.http.HttpServletRequest;
import java.util.HashMap;
import java.util.Map;

/**
 * Author: Grissom
 * Date: 2020/7/16 6:06 下午
 * Description: 全局异常处理类，用于统一处理控制器层抛出的异常。
 * 通过@ControllerAdvice注解实现AOP方式的异常拦截，集中处理各种异常情况，
 * 返回统一的错误响应格式，避免异常信息直接暴露给客户端。
 * 当前主要处理参数校验异常(MethodArgumentNotValidException)，
 * 返回400状态码和具体的校验错误信息。
 */
@ControllerAdvice // aop
public class Handler {

    @org.springframework.web.bind.annotation.ExceptionHandler(MethodArgumentNotValidException.class)
    @ResponseStatus(HttpStatus.BAD_REQUEST)
    @ResponseBody
    public Map<String, Object> methodArgumentNotValidExceptionHandle(HttpServletRequest request,
            MethodArgumentNotValidException e) {
        Map<String, Object> result = new HashMap<>();
        result.put("error", e.getBindingResult().getAllErrors().get(0).getDefaultMessage());
        return result;
    }
}

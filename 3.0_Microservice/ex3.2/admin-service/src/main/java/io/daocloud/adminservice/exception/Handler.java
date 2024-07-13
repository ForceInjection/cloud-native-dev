package io.daocloud.adminservice.exception;

import org.springframework.http.HttpStatus;
import org.springframework.web.bind.MethodArgumentNotValidException;
import org.springframework.web.bind.annotation.ControllerAdvice;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.bind.annotation.ResponseStatus;

import javax.servlet.http.HttpServletRequest;
import java.util.HashMap;
import java.util.Map;

/**
 * Author: Garroshh
 * date: 2020/7/16 6:06 下午
 */
@ControllerAdvice //aop
public class Handler {

    @org.springframework.web.bind.annotation.ExceptionHandler(MethodArgumentNotValidException.class)
    @ResponseStatus(HttpStatus.BAD_REQUEST)
    @ResponseBody
    public Map methodArgumentNotValidExceptionHandle(HttpServletRequest request, MethodArgumentNotValidException e) {
        Map result = new HashMap();
        result.put("error", e.getBindingResult().getAllErrors().get(0).getDefaultMessage());
        return result;
    }
}

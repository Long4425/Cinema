/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package exception;

/**
 *
 * @author Nguyen Dinh Giap
 */


/**
 * DataAccessException ------------------- Exception runtime chung cho tầng DAO.
 * Dùng để wrap các SQLException và các lỗi truy xuất DB khác.
 *
 * Ưu điểm: - Không buộc try-catch ở tầng trên (RuntimeException) - Cho phép
 * Service quyết định cách phản hồi hoặc rollback
 */
public class DataAccessException extends RuntimeException {

    public DataAccessException(String message, Throwable cause) {
        super(message, cause);
    }

    public DataAccessException(String message) {
        super(message);
    }

    public DataAccessException(Throwable cause) {
        super(cause);
    }
}

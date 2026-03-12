package controller.payment;

import dao.BookingDAO;
import dao.BookingSeatDAO;
import dao.PaymentDAO;
import model.Payment;
import util.VNPayConfig;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.nio.charset.StandardCharsets;
import java.time.LocalDateTime;
import java.util.*;

@WebServlet(name = "VNPayReturnServlet", urlPatterns = {"/payment/vnpay-return"})
public class VNPayReturnServlet extends HttpServlet {

    private final PaymentDAO paymentDAO = new PaymentDAO();
    private final BookingDAO bookingDAO = new BookingDAO();
    private final BookingSeatDAO bookingSeatDAO = new BookingSeatDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        Map<String, String> fields = new HashMap<>();
        for (Enumeration<String> params = request.getParameterNames(); params.hasMoreElements(); ) {
            String fieldName = params.nextElement();
            String fieldValue = request.getParameter(fieldName);
            if (fieldValue != null && !fieldValue.isEmpty()) {
                String encodedName = java.net.URLEncoder.encode(fieldName, StandardCharsets.UTF_8.toString());
                String encodedValue = java.net.URLEncoder.encode(fieldValue, StandardCharsets.UTF_8.toString());
                fields.put(encodedName, encodedValue);
            }
        }

        String vnp_SecureHash = request.getParameter("vnp_SecureHash");

        try {
            String encodedHashType = java.net.URLEncoder.encode("vnp_SecureHashType", StandardCharsets.UTF_8.toString());
            String encodedHash = java.net.URLEncoder.encode("vnp_SecureHash", StandardCharsets.UTF_8.toString());
            fields.remove(encodedHashType);
            fields.remove(encodedHash);
        } catch (Exception e) {
            fields.remove("vnp_SecureHashType");
            fields.remove("vnp_SecureHash");
        }

        String signValue = VNPayConfig.hashAllFields(fields);
        boolean isValidSignature = signValue.equals(vnp_SecureHash);

        String vnp_TxnRef = request.getParameter("vnp_TxnRef");
        String vnp_Amount = request.getParameter("vnp_Amount");
        String vnp_OrderInfo = request.getParameter("vnp_OrderInfo");
        String vnp_ResponseCode = request.getParameter("vnp_ResponseCode");
        String vnp_TransactionNo = request.getParameter("vnp_TransactionNo");
        String vnp_BankCode = request.getParameter("vnp_BankCode");
        String vnp_PayDate = request.getParameter("vnp_PayDate");
        String vnp_TransactionStatus = request.getParameter("vnp_TransactionStatus");

        request.setAttribute("vnp_TxnRef", vnp_TxnRef);
        request.setAttribute("vnp_Amount", vnp_Amount);
        request.setAttribute("vnp_OrderInfo", vnp_OrderInfo);
        request.setAttribute("vnp_ResponseCode", vnp_ResponseCode);
        request.setAttribute("vnp_TransactionNo", vnp_TransactionNo);
        request.setAttribute("vnp_BankCode", vnp_BankCode);
        request.setAttribute("vnp_PayDate", vnp_PayDate);
        request.setAttribute("vnp_TransactionStatus", vnp_TransactionStatus);
        request.setAttribute("isValidSignature", isValidSignature);

        String paymentStatus;
        String message;

        int bookingId = extractBookingIdFromTxnRef(vnp_TxnRef);

        try {
            Payment payment = (vnp_TxnRef != null && !vnp_TxnRef.isBlank())
                    ? paymentDAO.findByTransactionRef(vnp_TxnRef)
                    : null;

            if (isValidSignature && "00".equals(vnp_ResponseCode) && "00".equals(vnp_TransactionStatus)) {
                paymentStatus = "success";
                message = "Thanh toán VNPay thành công.";

                if (payment != null) {
                    paymentDAO.updateStatus(payment.getPaymentId(), "Success", LocalDateTime.now());
                }
                if (bookingId > 0) {
                    bookingDAO.updateStatus(bookingId, "Confirmed");
                    bookingSeatDAO.updateStatusByBooking(bookingId, "Confirmed");
                }
            } else {
                paymentStatus = "failed";
                message = "Thanh toán thất bại hoặc bị hủy. Bạn có thể thử lại.";

                if (payment != null) {
                    paymentDAO.updateStatus(payment.getPaymentId(), "Failed", null);
                }
                if (bookingId > 0) {
                    bookingDAO.updateStatus(bookingId, "Pending");
                    bookingSeatDAO.updateStatusByBooking(bookingId, "Cancelled");
                }
            }
        } catch (Exception e) {
            paymentStatus = "failed";
            message = "Lỗi xử lý kết quả thanh toán: " + e.getMessage();
        }

        request.setAttribute("paymentStatus", paymentStatus);
        request.setAttribute("message", message);
        request.setAttribute("bookingId", bookingId);

        request.getRequestDispatcher("/booking/payment-result.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doGet(request, response);
    }

    private int extractBookingIdFromTxnRef(String txnRef) {
        try {
            if (txnRef != null && txnRef.startsWith("BOOK")) {
                String idPart = txnRef.substring(4);
                int underscore = idPart.indexOf('_');
                if (underscore > 0) {
                    return Integer.parseInt(idPart.substring(0, underscore));
                }
            }
        } catch (Exception ignored) {
        }
        return 0;
    }
}


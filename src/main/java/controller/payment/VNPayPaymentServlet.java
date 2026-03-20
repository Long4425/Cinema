package controller.payment;

import dao.BookingDAO;
import dao.PaymentDAO;
import exception.DataAccessException;
import model.Booking;
import model.Payment;
import util.VNPayConfig;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.math.BigDecimal;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.time.LocalDateTime;
import java.time.ZoneId;
import java.time.format.DateTimeFormatter;
import java.util.*;

@WebServlet(name = "VNPayPaymentServlet", urlPatterns = {"/payment/vnpay"})
public class VNPayPaymentServlet extends HttpServlet {

    private final BookingDAO bookingDAO = new BookingDAO();
    private final PaymentDAO paymentDAO = new PaymentDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String bookingIdStr = request.getParameter("bookingId");
        if (bookingIdStr == null || bookingIdStr.isBlank()) {
            response.sendRedirect(request.getContextPath() + "/showtimes");
            return;
        }

        try {
            int bookingId = Integer.parseInt(bookingIdStr);
            Booking booking = bookingDAO.findById(bookingId);
            if (booking == null) {
                response.sendRedirect(request.getContextPath() + "/showtimes");
                return;
            }

            // Tổng tiền booking tính bằng VND, VNPay dùng đơn vị "đồng x 100"
            BigDecimal amountVnd = booking.getTotalAmount();
            long amount = amountVnd.multiply(BigDecimal.valueOf(100L)).longValue();

            String vnp_Version = "2.1.0";
            String vnp_Command = "pay";
            String orderType = "billpayment";

            String vnp_TxnRef = "BOOK" + bookingId + "_" + VNPayConfig.getRandomNumber(6);
            String vnp_IpAddr = VNPayConfig.getIpAddress(request);
            String vnp_TmnCode = VNPayConfig.vnp_TmnCode;

            Map<String, String> vnp_Params = new HashMap<>();
            vnp_Params.put("vnp_Version", vnp_Version);
            vnp_Params.put("vnp_Command", vnp_Command);
            vnp_Params.put("vnp_TmnCode", vnp_TmnCode);
            vnp_Params.put("vnp_Amount", String.valueOf(amount));
            vnp_Params.put("vnp_CurrCode", "VND");
            vnp_Params.put("vnp_TxnRef", vnp_TxnRef);
            vnp_Params.put("vnp_OrderInfo", "Thanh toan ve xem phim #" + bookingId);
            vnp_Params.put("vnp_OrderType", orderType);
            vnp_Params.put("vnp_Locale", "vn");
            vnp_Params.put("vnp_ReturnUrl", VNPayConfig.getReturnUrl(request));
            vnp_Params.put("vnp_IpAddr", vnp_IpAddr);

            // Thời gian tạo + hết hạn (15 phút)
            DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyyMMddHHmmss");
            LocalDateTime now = LocalDateTime.now(ZoneId.of("Asia/Ho_Chi_Minh"));
            String vnp_CreateDate = now.format(formatter);
            String vnp_ExpireDate = now.plusMinutes(15).format(formatter);
            vnp_Params.put("vnp_CreateDate", vnp_CreateDate);
            vnp_Params.put("vnp_ExpireDate", vnp_ExpireDate);

            List<String> fieldNames = new ArrayList<>(vnp_Params.keySet());
            Collections.sort(fieldNames);

            List<String> hashDataList = new ArrayList<>();
            List<String> queryList = new ArrayList<>();

            for (String fieldName : fieldNames) {
                String fieldValue = vnp_Params.get(fieldName);
                if (fieldValue != null && !fieldValue.isEmpty()) {
                    String encodedValue = URLEncoder.encode(fieldValue, StandardCharsets.UTF_8.toString());
                    hashDataList.add(fieldName + "=" + encodedValue);
                    queryList.add(URLEncoder.encode(fieldName, StandardCharsets.UTF_8.toString())
                            + "=" + encodedValue);
                }
            }

            String hashData = String.join("&", hashDataList);
            String queryUrl = String.join("&", queryList);

            String vnp_SecureHash = VNPayConfig.hmacSHA512(VNPayConfig.secretKey, hashData);
            queryUrl += "&vnp_SecureHash=" + vnp_SecureHash;
            String paymentUrl = VNPayConfig.vnp_PayUrl + "?" + queryUrl;

            // Lưu payment pending
            Payment payment = new Payment();
            payment.setBookingId(bookingId);
            payment.setPaymentMethod("VNPay");
            payment.setAmount(amountVnd);
            payment.setStatus("Pending");
            payment.setTransactionRef(vnp_TxnRef);
            paymentDAO.create(payment);

            bookingDAO.updateStatus(bookingId, "Pending");

            response.sendRedirect(paymentUrl);
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/showtimes");
        } catch (DataAccessException e) {
            request.getSession().setAttribute("error", "Lỗi tạo giao dịch thanh toán: " + e.getMessage());
            response.sendRedirect(request.getContextPath() + "/showtimes");
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doGet(request, response);
    }
}


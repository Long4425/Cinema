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
import java.math.RoundingMode;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.text.SimpleDateFormat;
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
            response.sendRedirect(request.getContextPath() + "/movies");
            return;
        }

        try {
            int bookingId = Integer.parseInt(bookingIdStr);
            Booking booking = bookingDAO.findById(bookingId);
            if (booking == null) {
                response.sendRedirect(request.getContextPath() + "/movies");
                return;
            }

            // Tổng tiền booking tính bằng VND, VNPay dùng đơn vị "đồng x 100"
            BigDecimal amountVnd = booking.getTotalAmount();
            if (amountVnd == null) {
                response.sendRedirect(request.getContextPath() + "/movies");
                return;
            }

            // VNPay yêu cầu vnp_Amount là số nguyên (không phải BigDecimal dạng thập phân).
            BigDecimal amountVndInt = amountVnd.setScale(0, RoundingMode.HALF_UP);
            long amount = amountVndInt.longValue() * 100L;
            if (amount <= 0) {
                response.sendRedirect(request.getContextPath() + "/movies");
                return;
            }

            String vnp_Version = "2.1.0";
            String vnp_Command = "pay";
            String orderType = "other";

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
            vnp_Params.put("vnp_OrderInfo", "Thanh toan ve xem phim " + bookingId);
            vnp_Params.put("vnp_OrderType", orderType);
            vnp_Params.put("vnp_Locale", "vn");
            vnp_Params.put("vnp_ReturnUrl", VNPayConfig.getReturnUrl(request));
            vnp_Params.put("vnp_IpAddr", vnp_IpAddr);

            // Thời gian tạo + hết hạn (15 phút)
            Calendar cld = Calendar.getInstance(TimeZone.getTimeZone("Etc/GMT+7"));
            SimpleDateFormat formatter = new SimpleDateFormat("yyyyMMddHHmmss");
            String vnp_CreateDate = formatter.format(cld.getTime());
            vnp_Params.put("vnp_CreateDate", vnp_CreateDate);
            cld.add(Calendar.MINUTE, 15);
            String vnp_ExpireDate = formatter.format(cld.getTime());
            vnp_Params.put("vnp_ExpireDate", vnp_ExpireDate);

            List<String> fieldNames = new ArrayList<>(vnp_Params.keySet());
            Collections.sort(fieldNames);

            List<String> hashDataList = new ArrayList<>();
            List<String> queryList = new ArrayList<>();

            for (String fieldName : fieldNames) {
                String fieldValue = vnp_Params.get(fieldName);
                if (fieldValue != null && !fieldValue.isEmpty()) {
                    String encodedValue = URLEncoder.encode(fieldValue, StandardCharsets.UTF_8);
                    hashDataList.add(fieldName + "=" + encodedValue);
                    queryList.add(URLEncoder.encode(fieldName, StandardCharsets.UTF_8)
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
            response.sendRedirect(request.getContextPath() + "/movies");
        } catch (DataAccessException e) {
            request.getSession().setAttribute("error", "Lỗi tạo giao dịch thanh toán: " + e.getMessage());
            response.sendRedirect(request.getContextPath() + "/movies");
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        doGet(request, response);
    }
}


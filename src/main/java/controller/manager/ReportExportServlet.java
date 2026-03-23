package controller.manager;

import dao.ReportDAO;
import model.RevenueRow;

import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import org.apache.poi.ss.usermodel.*;
import org.apache.poi.ss.util.CellRangeAddress;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;

import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

@WebServlet(name = "ReportExportServlet", urlPatterns = {"/manager/export"})
public class ReportExportServlet extends HttpServlet {

    private static final Logger LOG = Logger.getLogger(ReportExportServlet.class.getName());
    private final ReportDAO reportDAO = new ReportDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) {
        LocalDate to = parseDate(req.getParameter("toDate"), LocalDate.now());
        LocalDate from = parseDate(req.getParameter("fromDate"), to.minusDays(6));
        Integer movieId = parseInt(req.getParameter("movieId"));
        Integer roomId = parseInt(req.getParameter("roomId"));

        List<RevenueRow> rows = reportDAO.getRevenue(from, to, movieId, roomId);

        resp.setContentType("application/vnd.openxmlformats-officedocument.spreadsheetml.sheet");
        resp.setHeader("Content-Disposition",
                "attachment; filename=\"revenue-report-" + from + "-to-" + to + ".xlsx\"");

        byte[] excelBytes;
        try (XSSFWorkbook wb = new XSSFWorkbook();
             ByteArrayOutputStream buf = new ByteArrayOutputStream()) {
            Sheet sheet = wb.createSheet("Doanh thu");
            sheet.setDefaultColumnWidth(18);

            // Styles
            CellStyle titleStyle = wb.createCellStyle();
            Font titleFont = wb.createFont();
            titleFont.setBold(true);
            titleFont.setFontHeightInPoints((short) 14);
            titleStyle.setFont(titleFont);
            titleStyle.setAlignment(HorizontalAlignment.CENTER);

            CellStyle headerStyle = wb.createCellStyle();
            Font headerFont = wb.createFont();
            headerFont.setBold(true);
            headerFont.setColor(IndexedColors.WHITE.getIndex());
            headerStyle.setFont(headerFont);
            headerStyle.setFillForegroundColor(IndexedColors.DARK_BLUE.getIndex());
            headerStyle.setFillPattern(FillPatternType.SOLID_FOREGROUND);
            headerStyle.setAlignment(HorizontalAlignment.CENTER);
            headerStyle.setBorderBottom(BorderStyle.THIN);

            CellStyle currencyStyle = wb.createCellStyle();
            DataFormat fmt = wb.createDataFormat();
            currencyStyle.setDataFormat(fmt.getFormat("#,##0"));
            currencyStyle.setAlignment(HorizontalAlignment.RIGHT);

            CellStyle percentStyle = wb.createCellStyle();
            percentStyle.setDataFormat(fmt.getFormat("0.00\"%\""));
            percentStyle.setAlignment(HorizontalAlignment.RIGHT);

            CellStyle centerStyle = wb.createCellStyle();
            centerStyle.setAlignment(HorizontalAlignment.CENTER);

            CellStyle totalLabelStyle = wb.createCellStyle();
            Font boldFont = wb.createFont();
            boldFont.setBold(true);
            totalLabelStyle.setFont(boldFont);

            CellStyle totalCurrencyStyle = wb.createCellStyle();
            totalCurrencyStyle.setFont(boldFont);
            totalCurrencyStyle.setDataFormat(fmt.getFormat("#,##0"));
            totalCurrencyStyle.setAlignment(HorizontalAlignment.RIGHT);

            // Row 0: Tiêu đề
            Row titleRow = sheet.createRow(0);
            Cell titleCell = titleRow.createCell(0);
            titleCell.setCellValue("BÁO CÁO DOANH THU");
            titleCell.setCellStyle(titleStyle);
            sheet.addMergedRegion(new CellRangeAddress(0, 0, 0, 6));

            // Row 1: Khoảng thời gian
            Row subRow = sheet.createRow(1);
            subRow.createCell(0).setCellValue("Khoảng thời gian: " + from + " → " + to);
            sheet.addMergedRegion(new CellRangeAddress(1, 1, 0, 6));

            // Row 2: trống
            sheet.createRow(2);

            // Row 3: Header
            String[] headers = {"Ngày", "Phim", "Phòng", "Doanh thu (₫)", "Số vé", "Số suất", "Tỷ lệ lấp đầy"};
            Row headerRow = sheet.createRow(3);
            for (int i = 0; i < headers.length; i++) {
                Cell c = headerRow.createCell(i);
                c.setCellValue(headers[i]);
                c.setCellStyle(headerStyle);
            }

            // Data rows
            BigDecimal sumRevenue = BigDecimal.ZERO;
            int sumTickets = 0;
            int dataRowIdx = 4;

            for (RevenueRow r : rows) {
                Row row = sheet.createRow(dataRowIdx++);

                Cell dateCell = row.createCell(0);
                dateCell.setCellValue(r.getDate() != null ? r.getDate().toString() : "");
                dateCell.setCellStyle(centerStyle);

                row.createCell(1).setCellValue(r.getMovieTitle() != null ? r.getMovieTitle() : "");
                row.createCell(2).setCellValue(r.getRoomName() != null ? r.getRoomName() : "");

                Cell revCell = row.createCell(3);
                revCell.setCellValue(r.getRevenue() != null ? r.getRevenue().doubleValue() : 0);
                revCell.setCellStyle(currencyStyle);

                Cell ticketCell = row.createCell(4);
                ticketCell.setCellValue(r.getTickets());
                ticketCell.setCellStyle(centerStyle);

                Cell showCell = row.createCell(5);
                showCell.setCellValue(r.getShowCount());
                showCell.setCellStyle(centerStyle);

                Cell occCell = row.createCell(6);
                occCell.setCellValue(r.getOccupancyRate() * 100.0);
                occCell.setCellStyle(percentStyle);

                if (r.getRevenue() != null) sumRevenue = sumRevenue.add(r.getRevenue());
                sumTickets += r.getTickets();
            }

            // Tổng cộng
            Row totalRow = sheet.createRow(dataRowIdx);
            Cell totalLabel = totalRow.createCell(0);
            totalLabel.setCellValue("TỔNG CỘNG");
            totalLabel.setCellStyle(totalLabelStyle);
            sheet.addMergedRegion(new CellRangeAddress(dataRowIdx, dataRowIdx, 0, 2));

            Cell totalRev = totalRow.createCell(3);
            totalRev.setCellValue(sumRevenue.doubleValue());
            totalRev.setCellStyle(totalCurrencyStyle);

            Cell totalTickets = totalRow.createCell(4);
            totalTickets.setCellValue(sumTickets);
            totalTickets.setCellStyle(totalLabelStyle);

            // Cột phim rộng hơn
            sheet.setColumnWidth(1, 40 * 256);

            wb.write(buf);
            excelBytes = buf.toByteArray();
        } catch (IOException e) {
            LOG.log(Level.SEVERE, "Lỗi tạo file Excel", e);
            resp.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            return;
        }
        try {
            resp.getOutputStream().write(excelBytes);
        } catch (IOException e) {
            LOG.log(Level.SEVERE, "Lỗi ghi response Excel", e);
        }
    }

    private LocalDate parseDate(String s, LocalDate fallback) {
        try {
            if (s == null || s.isBlank()) return fallback;
            return LocalDate.parse(s.trim());
        } catch (Exception e) {
            return fallback;
        }
    }

    private Integer parseInt(String s) {
        try {
            if (s == null || s.isBlank()) return null;
            return Integer.parseInt(s.trim());
        } catch (Exception e) {
            return null;
        }
    }
}

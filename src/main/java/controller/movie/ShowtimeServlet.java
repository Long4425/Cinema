package controller.movie;

import dao.ShowtimeDAO;
import model.Showtime;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.time.LocalDate;
import java.util.List;

/**
 * UC-06 | View showtimes
 * Filter showtimes by date.
 */
@WebServlet(name = "ShowtimeServlet", urlPatterns = {"/showtimes"})
public class ShowtimeServlet extends HttpServlet {

    private final ShowtimeDAO showtimeDAO = new ShowtimeDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String dateStr = req.getParameter("date");
        LocalDate date;
        if (dateStr == null || dateStr.isEmpty()) {
            date = LocalDate.now();
        } else {
            try {
                date = LocalDate.parse(dateStr);
            } catch (Exception e) {
                date = LocalDate.now();
            }
        }

        List<Showtime> showtimes = showtimeDAO.findByDate(date);

        req.setAttribute("showtimes", showtimes);
        req.setAttribute("date", date);
        req.getRequestDispatcher("/movie/showtimes.jsp").forward(req, resp);
    }
}

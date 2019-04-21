import java.sql.*;
import java.util.List;

// If you are looking for Java data structures, these are highly useful.
// Remember that an important part of your mark is for doing as much in SQL (not Java) as you can.
// Solutions that use only or mostly Java will not receive a high mark.
//import java.util.ArrayList;
//import java.util.Map;
//import java.util.HashMap;
//import java.util.Set;
//import java.util.HashSet;
public class Assignment2 extends JDBCSubmission {

    public Assignment2() throws ClassNotFoundException {

        Class.forName("org.postgresql.Driver");
    }

    @Override
    public boolean connectDB(String url, String username, String password) {
        // Implement this method!
        try {
            connection = DriverManager.getConnection(url, username, password);
        } catch (SQLException se) {
            System.err.println("SQL Exception." +
                    "<Message>: " + se.getMessage());
            return false;
        }
        return true;
    }

    @Override
    public boolean disconnectDB() {
        // Implement this method!
        if (connection != null) {
            try {
                connection.close();
            } catch (SQLException se) {
                System.err.println("SQL Exception." +
                        "<Message>: " + se.getMessage());
                return false;
            }
        }
        return true;
    }

    @Override
    public ElectionCabinetResult electionSequence(String countryName) {
        // Implement this method!
        List<Integer> elections = new ArrayList<>();
        List<Integer> cabinets = new ArrayList<>();

        try {
            String queryString = "SELECT election.id AS election_id, cabinet.id AS cabinet_id " +
                "    FROM election JOIN country ON election.country_id = country.id JOIN cabinet ON election.id = cabinet.election_id " +
                "    WHERE country.name = ? " +
                "    ORDER BY election.e_date desc;";

            PreparedStatement ps = connection.prepareStatement(queryString);
            ps.setString(1, countryName);

            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                elections.add(rs.getInt("election_id"));
                cabinets.add(rs.getInt("cabinet_id"));
            }
        } catch (SQLException se) {
            System.err.println("SQL Exception." +
                        "<Message>: " + se.getMessage());
        }

        return new ElectionCabinetResult(elections, cabinets);
    }

    @Override
    public List<Integer> findSimilarPoliticians(Integer politicianName, Float threshold) {
        // Implement this method!
        List<Integer> ids = new ArrayList<>();

        try {
            String desCom = new String("");
            String comDes = new String("");
            String queryString = "SELECT description, comment FROM politician_president WHERE politician_president.id = ?";
            PreparedStatement ps = connection.prepareStatement(queryString);
            ps.setInt(1, politicianName);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                desCom = rs.getString(1) + rs.getString(2);
                comDes = rs.getString(2) + rs.getString(1);
            }


            String des = new String("");
            String com = new String("");
            String queryString1 = "SELECT id, description, comment FROM politician_president WHERE id <> ?";
            PreparedStatement ps1 = connection.prepareStatement(queryString1);
            ps.setInt(1, politicianName);
            ResultSet rs1 = ps1.executeQuery();
            while (rs1.next()) {
                des = rs1.getString(2);
                com = rs1.getString(3);
                if (similarity(desCom, des + com) >= threshold || similarity(comDes, com + des) >= threshold) {
                    int id = rs1.getInt("id");
                    ids.add(id);
                }
            }
        } catch (SQLException se) {
            System.err.println("SQL Exception." +
                    "<Message>: " + se.getMessage());
        }

        return ids;
    }

    public static void main(String[] args) {
        // You can put testing code in here. It will not affect our autotester.
        System.out.println("Hello");
    }

}

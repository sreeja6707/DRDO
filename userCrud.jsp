<%@ page import="java.sql.*" %>
<html>
<head>
    <title>User Management</title>
    <style>
        body { font-family: Arial, sans-serif; }
        form {
            margin: 20px auto;
            width: 350px;
            padding: 15px;
            border: 1px solid #ccc;
            border-radius: 8px;
        }
        input[type=text], input[type=email], input[type=number] {
            width: 95%;
            padding: 8px;
            margin: 8px 0;
        }
        input[type=submit], button {
            margin: 5px 2px;
            background-color: #007bff;
            color: white;
            border: none;
            padding: 10px;
            width: 32%;
            cursor: pointer;
            border-radius: 5px;
        }
        .btn-update { background: orange; }
        .btn-delete { background: red; }
        .btn-cancel { background: gray; width: 100%; }
        table {
            border-collapse: collapse;
            width: 90%;
            margin: 20px auto;
        }
        th, td {
            border: 1px solid #444;
            padding: 8px;
            text-align: center;
        }
        th { background-color: #f2f2f2; }
        tr:hover { background-color: #f9f9f9; }
    </style>

    <script>
        function confirmAction(actionType) {
            return confirm("Are you sure you want to " + actionType + " this user?");
        }
    </script>
</head>
<body>
<h2 style="text-align:center;">User Registration / Management</h2>

<%
    Connection con = null;
    PreparedStatement ps = null;
    Statement stmt = null;
    ResultSet rs = null;

    String action = request.getParameter("action");
    String id = request.getParameter("id");
    String name = request.getParameter("name");
    String email = request.getParameter("email");
    String gender = request.getParameter("gender");
    String age = request.getParameter("age");

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        con = DriverManager.getConnection(
            "jdbc:mysql://localhost:3306/userdb?useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=UTC",
            "tomcatuser",
            "tomcat123"
        );

        // --- Perform CRUD ---
        if("insert".equals(action) && name != null && email != null && gender != null && age != null){
            ps = con.prepareStatement("INSERT INTO user3 (name, email, gender, age) VALUES (?, ?, ?, ?)");
            ps.setString(1, name);
            ps.setString(2, email);
            ps.setString(3, gender);
            ps.setInt(4, Integer.parseInt(age));
            ps.executeUpdate();
            out.println("<p style='color:green;text-align:center;'>✅ User added!</p>");
        }
        else if("update".equals(action) && id != null){
            ps = con.prepareStatement("UPDATE user3 SET name=?, email=?, gender=?, age=? WHERE id=?");
            ps.setString(1, name);
            ps.setString(2, email);
            ps.setString(3, gender);
            ps.setInt(4, Integer.parseInt(age));
            ps.setInt(5, Integer.parseInt(id));
            ps.executeUpdate();
            out.println("<p style='color:blue;text-align:center;'>✏️ User updated!</p>");
        }
        else if("delete".equals(action) && id != null){
            ps = con.prepareStatement("DELETE FROM user3 WHERE id=?");
            ps.setInt(1, Integer.parseInt(id));
            ps.executeUpdate();
            out.println("<p style='color:red;text-align:center;'>🗑️ User deleted!</p>");
        }

        // --- Edit Mode ---
        String selectedId = request.getParameter("selectedId");
        String editName = "";
        String editEmail = "";
        String editGender = "";
        String editAge = "";
        String formAction = "insert";
        boolean isEditMode = false;

        if(selectedId != null){
            stmt = con.createStatement();
            rs = stmt.executeQuery("SELECT * FROM user3 WHERE id=" + selectedId);
            if(rs.next()){
                id = rs.getString("id");
                editName = rs.getString("name");
                editEmail = rs.getString("email");
                editGender = rs.getString("gender");
                editAge = rs.getString("age");
                formAction = "update&id=" + id;
                isEditMode = true;
            }
            rs.close(); stmt.close();
        }
%>

<!-- User Form -->
<form method="post" action="userCrud.jsp?action=<%=formAction%>" 
      onsubmit="return confirmAction('<%= (isEditMode ? "update" : "insert") %>');">
    <label>Name:</label><br>
    <input type="text" name="name" value="<%=editName%>" required><br>
    
    <label>Email:</label><br>
    <input type="email" name="email" value="<%=editEmail%>" required><br>
    
    <label>Gender:</label><br>
<select name="gender" style="width:95%; padding:8px; margin:8px 0;" required>
    <option value="">--Select Gender--</option>
    <option value="Male" <%= "Male".equals(editGender) ? "selected" : "" %>>Male</option>
    <option value="Female" <%= "Female".equals(editGender) ? "selected" : "" %>>Female</option>
    <option value="Other" <%= "Other".equals(editGender) ? "selected" : "" %>>Other</option>
</select><br>


    <label>Age:</label><br>
    <input type="number" name="age" value="<%=editAge%>" required><br>
    
    <% if(isEditMode) { %>
        <input type="hidden" name="id" value="<%=id%>">
        <input type="submit" class="btn-update" value="Update">
        <button formaction="userCrud.jsp?action=delete&id=<%=id%>" 
                class="btn-delete" 
                onclick="return confirmAction('delete');">Delete</button>
        <button formaction="userCrud.jsp" class="btn-cancel">Cancel</button>
    <% } else { %>
        <input type="submit" value="Add User">
    <% } %>
</form>

<%
    // --- Display all users in table with actions ---
    stmt = con.createStatement();
    rs = stmt.executeQuery("SELECT * FROM user3");

    out.println("<h3 style='text-align:center;'>All Users</h3>");
    out.println("<table>");
    out.println("<tr><th>ID</th><th>Name</th><th>Email</th><th>Gender</th><th>Age</th><th>Actions</th></tr>");

    boolean hasData = false;
    while(rs.next()) {
        hasData = true;
        int uid = rs.getInt("id");
        String uname = rs.getString("name");
        String uemail = rs.getString("email");
        String ugender = rs.getString("gender");
        int uage = rs.getInt("age");

        out.println("<tr>");
        out.println("<td>" + uid + "</td>");
        out.println("<td>" + uname + "</td>");
        out.println("<td>" + uemail + "</td>");
        out.println("<td>" + ugender + "</td>");
        out.println("<td>" + uage + "</td>");
        out.println("<td>");
        
        // Update button
        out.println("<form style='display:inline;' method='get' action='userCrud.jsp'>");
        out.println("<input type='hidden' name='selectedId' value='" + uid + "'>");
        out.println("<input type='submit' class='btn-update' value='Update'>");
        out.println("</form>");
        out.println("&nbsp;");
        
        // Delete button
        out.println("<form style='display:inline;' method='post' action='userCrud.jsp?action=delete&id=" + uid + "' onsubmit=\"return confirmAction('delete');\">");
        out.println("<input type='submit' class='btn-delete' value='Delete'>");
        out.println("</form>");

        out.println("</td>");
        out.println("</tr>");
    }

    if(!hasData){
        out.println("<tr><td colspan='6'>No users found</td></tr>");
    }

    out.println("</table>");
} catch(Exception e) {
    out.println("<p style='color:red;text-align:center;'>❌ Error: " + e.getMessage() + "</p>");
} finally {
    if(rs != null) try { rs.close(); } catch(Exception ignore) {}
    if(stmt != null) try { stmt.close(); } catch(Exception ignore) {}
    if(ps != null) try { ps.close(); } catch(Exception ignore) {}
    if(con != null) try { con.close(); } catch(Exception ignore) {}
}
%>

</body>
</html>

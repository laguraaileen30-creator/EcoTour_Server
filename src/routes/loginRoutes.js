router.post("/login", async (req, res) => {

    const { email, password } = req.body;

    const [rows] = await db.query(
        "SELECT * FROM users WHERE email=?",
        [email]
    );

    if (rows.length === 0) {
        return res.status(401).json({
            success:false,
            message:"Invalid email or password"
        });
    }

    const user = rows[0];

    // Temporary plain-text comparison
    if (password !== user.password) {
        return res.status(401).json({
            success:false,
            message:"Invalid email or password"
        });
    }

    res.json({
        success:true,
        user:{
            user_id:user.user_id,
            fname:user.fname,
            lname:user.lname,
            role:user.role,
            status:user.status,
            email:user.email
        }
    });

});
import { Button, Container, TextField, Typography } from "@mui/material"
import { useState } from "react"
import { loginUser } from "../data/LocalStorageDB";

const LoginPage = () => {
    const [username, setUsername] = useState('');
    const [password, setPassword] = useState('');

    const login = () => {
        if(username !== '' && password !== '') {
            const user = loginUser(username, password)
            if (user) {
                window.location.reload()
            } else {
                window.alert('Incorrect username or password')
            }
        }
    }
    return <Container maxWidth="xs" className="page">
        <br />
        <br />
        <Typography
            variant="h5"
            noWrap
            component="a"
            href="/"
            sx={{
                mr: 2,
                display: { xs: 'none', md: 'flex' },
                fontFamily: 'monospace',
                fontWeight: 700,
                letterSpacing: '.3rem',
                color: 'inherit',
                textDecoration: 'none',
            }}>
            TWIT
        </Typography>
        <br />
        <TextField id="username"
            label="Username"
            variant="outlined"
            fullWidth
            onChange={(e) => setUsername(e.target.value)} />
        <br />
        <br />
        <TextField
            id="password"
            label="Password"
            variant="outlined"
            type="password"
            fullWidth
            onChange={(e) => setPassword(e.target.value)} />
        <br />
        <br />
        <Button variant="contained" onClick={login}>Login</Button>
        <br />
        <br />
        <a href="/signup">New user? Sign Up</a>
    </Container>
}

export default LoginPage
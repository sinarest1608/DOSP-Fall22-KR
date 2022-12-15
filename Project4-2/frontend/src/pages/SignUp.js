import { Button, Container, TextField, Typography } from "@mui/material"
import { useState } from "react"
import { createUser } from "../data/LocalStorageDB";

const SignUpPage = () => {
    const [username, setUsername] = useState('');
    const [displayName, setDisplayName] = useState('');
    const [password, setPassword] = useState('');
    const [repeatPassword, setRepeatPassword] = useState('');

    const signUp = () => {
        if(username !== '' && password !== '' && repeatPassword !== '' && displayName !== '') {
            if (repeatPassword !== password) {
                window.alert('Passwords do not match')
            } else {
                const user = createUser({
                    username: username,
                    password: password,
                    displayName: displayName,
                    userSince: 'December 2022',
                    avatar: 'https://picsum.photos/200',
                })
                if (user) {
                    localStorage.setItem('loggedInUser', JSON.stringify(user))
                    window.location.href = '/'
                } else {
                    window.alert('An error occurred. Please try again.')
                }
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
            id="display-name"
            label="Display Name"
            variant="outlined"
            fullWidth
            onChange={(e) => setDisplayName(e.target.value)} />
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
        <TextField
            id="repeat-password"
            label="Repeat Password"
            variant="outlined"
            type="password"
            fullWidth
            onChange={(e) => setRepeatPassword(e.target.value)} />
        <br />
        <br />
        <Button variant="contained" onClick={signUp}>Sign Up</Button>
    </Container>
}

export default SignUpPage
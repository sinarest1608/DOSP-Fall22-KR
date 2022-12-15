import { Button, Container, TextField, Typography } from "@mui/material"
import { useState } from "react"
import Appbar from "../components/Appbar";
import { addTweet, createUser, getLoggedInUser } from "../data/LocalStorageDB";

const NewTwitPage = () => {
    const [content, setContent] = useState('');

    const newTwit = () => {
        if (content !== '') {
            addTweet({
                user: getLoggedInUser(),
                content: content
            })
            window.location.href = '/'
        }
    }
    return <Container maxWidth="xl" className="page">
        <Appbar />
        <Container maxWidth="md">
            <br />
            <Typography
                variant="h6"
                noWrap
                sx={{
                    mr: 2,
                    display: { xs: 'none', md: 'flex' },
                    fontFamily: 'monospace',
                    fontWeight: 700,
                    letterSpacing: ".4em",
                    color: 'inherit',
                    textDecoration: 'none',
                }}>
                NEW TWIT
            </Typography>
            <p>Signed in as {getLoggedInUser().displayName}</p>
            <br />
            <TextField id="username"
                label="Type something"
                multiline
                fullWidth
                onChange={(e) => setContent(e.target.value)} />
            <br />
            <br />
            <Button variant="contained" onClick={newTwit}>Twit</Button>
        </Container>
    </Container>
}

export default NewTwitPage
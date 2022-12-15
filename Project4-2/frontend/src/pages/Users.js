import { Container, Grid, Typography } from "@mui/material"
import Appbar from "../components/Appbar"
import UserListing from "../components/UserListing"
import { getAllUsers } from "../data/LocalStorageDB"

const UserListingPage = () => {
    
    return <Container className="page">
        <Appbar />
        <Container maxWidth="lg" className="page-content">
            <br />
            <Grid container spacing={2}>
                <Grid item xs={12}>
                    <Typography
                        variant="h6"
                        noWrap
                        sx={{
                            mr: 2,
                            display: { xs: 'none', md: 'flex' },
                            fontFamily: 'monospace',
                            fontWeight: 700,
                            color: 'inherit',
                            textDecoration: 'none',
                        }}>
                        Users
                    </Typography>
                </Grid>
                {
                    getAllUsers().map(user => {
                        return <Grid item xs={3} key={user.username}>
                            <UserListing user={user} />
                        </Grid>
                    })
                }
            </Grid>
        </Container>
    </Container>

}

export default UserListingPage
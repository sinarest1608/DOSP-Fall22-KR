import { AppBar, Button, Container, Toolbar, Typography } from '@mui/material';
import { logOutUser } from '../data/LocalStorageDB';

const Appbar = () => {
	return (
		<AppBar position="static">
			<Container maxWidth={false}>
				<Toolbar disableGutters>
					<Typography
						variant="h6"
						noWrap
						component="a"
						href="/"
						sx={{
							mr: 2,
							display: { xs: 'none', md: 'flex' },

							fontWeight: 700,
							flexGrow: 1,

							color: 'inherit',
							textDecoration: 'none'
						}}
					>
						TWITERRRRRR!
					</Typography>
					<Button color="inherit" onClick={() => (window.location.href = '/users')}>
						Users
					</Button>
					<Button color="inherit" onClick={() => logOutUser()}>
						Log Out
					</Button>
					<Button color="inherit" variant="outlined" onClick={() => (window.location.href = '/new')}>
						New Twit
					</Button>
				</Toolbar>
			</Container>
		</AppBar>
	);
};

export default Appbar;

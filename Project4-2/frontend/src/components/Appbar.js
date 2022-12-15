import { AppBar, Button, Container, Toolbar, Typography } from '@mui/material';
import { logOutUser } from '../data/LocalStorageDB';

const Appbar = () => {
	return (
		<AppBar elevation={0} position="static" style={{ background: '#1DA1F2' }}>
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
					<Button color="inherit" onClick={() => (window.location.href = '/search')}>
						Search
					</Button>
					<Button color="inherit" onClick={() => (window.location.href = '/users')}>
						Users
					</Button>
					<Button color="inherit" onClick={() => logOutUser()}>
						Log Out
					</Button>
					<Button color="inherit"  onClick={() => (window.location.href = '/new')}>
						Tweet
					</Button>
				</Toolbar>
			</Container>
		</AppBar>
	);
};

export default Appbar;

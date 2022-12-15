import { Container, Grid, Typography } from '@mui/material';
import Appbar from '../components/Appbar';
import UserListing from '../components/UserListing';
import { getAllUsers } from '../data/LocalStorageDB';

const UserListingPage = () => {
	return (
		<Container
			className="page"
			sx={{ margin: 0 }}
			maxWidth={false}
			style={{ background: '#1DA1F2', height: '100vh' }}
		>
			<Appbar />
			<Container maxWidth="lg" className="page-content">
				<br />
				<Grid container spacing={2}>
					<Grid item xs={12}>
						<Typography
							variant="h6"
							noWrap
							sx={{
								display: { xs: 'none', md: 'flex' },

								fontWeight: 700,
								color: 'white',
								textDecoration: 'none'
							}}
						>
							Users
						</Typography>
					</Grid>
					{getAllUsers().map((user) => {
						return (
							<Grid item xs={100} key={user.username}>
								<UserListing user={user} />
							</Grid>
						);
					})}
				</Grid>
			</Container>
		</Container>
	);
};

export default UserListingPage;

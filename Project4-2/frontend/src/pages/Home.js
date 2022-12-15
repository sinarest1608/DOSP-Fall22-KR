import FeedPage from './Feed';
import LoginPage from './Login';
import { getLoggedInUser } from '../data/LocalStorageDB';
import { AppBar, Button, Container, Toolbar, Typography } from '@mui/material';
import { alignProperty } from '@mui/material/styles/cssUtils';

const HomePage = () => {
	if (getLoggedInUser() === null) {
		return (
			<Container
				sx={{ margin: 0 }}
				maxWidth={false}
				style={{ background: '#1DA1F2', height: '100vh', justifyContent: 'center', display: 'flex' }}
			>
				<LoginPage />
			</Container>
		);
	} else {
		return <FeedPage />;
	}
};

export default HomePage;

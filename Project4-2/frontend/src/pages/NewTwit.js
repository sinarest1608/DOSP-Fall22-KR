import { Button, Container, TextField, Typography } from '@mui/material';
import { useState } from 'react';
import Appbar from '../components/Appbar';
import { addTweet, createUser, getLoggedInUser } from '../data/LocalStorageDB';

const NewTwitPage = () => {
	const [ content, setContent ] = useState('');

	const newTwit = () => {
		if (content !== '') {
			addTweet({
				user: getLoggedInUser(),
				content: content
			});
			window.location.href = '/';
		}
	};
	return (
		<Container maxWidth="xl" className="page" sx={{ margin: 0 }} style={{ background: '#1DA1F2', height: '100vh' }}>
			<Appbar />
			<Container
				maxWidth="md"
				className="page"
				style={{
					backgroundColor: 'white',
					alignSelf: 'center',
					alignmentBaseline: 'central',
					borderRadius: '10px'
				}}
			>
				<br />
				<Typography
					variant="h6"
					noWrap
					sx={{
						display: { xs: 'none', md: 'flex' },
						fontWeight: 700,
						color: 'black',
						textDecoration: 'none'
					}}
				>
					NEW TWITERRRRRR
				</Typography>
				<p>Only Text Allowed</p>
				<br />
				<TextField
					id="username"
					label="Type something"
					multiline
					fullWidth
					onChange={(e) => setContent(e.target.value)}
				/>
				<br />
				<br />
				<Button variant="contained" onClick={newTwit}>
					Post
				</Button>
				<br />
				<br />
			</Container>
		</Container>
	);
};

export default NewTwitPage;

import { Button, Container, FormControlLabel, FormGroup, Grid, Switch, Typography } from '@mui/material';
import { useState } from 'react';
import Appbar from '../components/Appbar';
import Tweet from '../components/Tweet';
import { getAllTweets } from '../data/LocalStorageDB';

const FeedPage = () => {
	const [ tweets, setTweets ] = useState(getAllTweets());
	
	return (
		<Container className="page">
			<Appbar />
			<Container maxWidth="lg" className="page-content">
				<br />
				<Grid container spacing={2}>
					<Grid item xs={9}>
						<Typography
							variant="h6"
							noWrap
							sx={{
								display: { xs: 'none', md: 'flex' },

								textDecoration: 'none'
							}}
						>
							Your Feed
						</Typography>
						<br />
						{tweets.length === 0 ? "It's Lonely out there!" : null}
					</Grid>
					<Grid item xs>
						<FormGroup>
							<FormControlLabel control={<Switch />} label="Subscribed only" />
						</FormGroup>
					</Grid>
					{tweets.map((tweet) => {
						return (
							<Grid item xs={12}>
								<Tweet content={tweet.content} createdAt={tweet.createdAt} user={tweet.user} />
							</Grid>
						);
					})}
				</Grid>
			</Container>
		</Container>
	);
};

export default FeedPage;

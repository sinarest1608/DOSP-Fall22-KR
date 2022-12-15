import { Button, Container, FormControlLabel, FormGroup, Grid, Switch, Typography, TextField, Box } from '@mui/material';
import { useState } from 'react';
import Appbar from '../components/Appbar';
import Tweet from '../components/Tweet';
import { getAllTweets } from '../data/LocalStorageDB';

const SearchPage = () => {
	const [ tweets, setTweets ] = useState(getAllTweets());
    const [query, setQuery] = useState("")
	return (
		<Container
			className="page"
			sx={{ margin: 0 }}
			maxWidth={false}
			style={{ background: '#1DA1F2', height: '100vh' }}
		>
			<Appbar />
            <Box
            component="form"
            sx={{
              '& .MuiTextField-root': { m: 1, width: '25ch', color:'white' },
              
            }}
            noValidate
            autoComplete="off">
                <div>
                <TextField

          id="outlined-required"
          label="Search Query"
          defaultValue=""
          sx={{color: 'white', outlineColor: 'white'}}
          onChange={event => setQuery(event.target.value)}
        />
                </div>
            </Box>
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
							Home
						</Typography>
						<br />
						{tweets.length === 0 ? "It's Lonely out there!" : null}
					</Grid>
					{/* <Grid item xs>
						<FormGroup>
							<FormControlLabel control={<Switch />} label="Following Only" />
						</FormGroup>
					</Grid> */}
					{tweets.map((tweet) => {
						if(tweet.content.includes(query)){
							return (
								<Grid item xs={12}>
									<Tweet content={tweet.content} createdAt={tweet.createdAt} user={tweet.user} />
								</Grid>
							);
						}
						return (
							<Container></Container>
						);
						
					})}
				</Grid>
			</Container>
		</Container>
	);
};

export default SearchPage;

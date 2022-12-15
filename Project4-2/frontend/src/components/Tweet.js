import { Avatar, Card, CardContent, CardHeader, Typography } from '@mui/material';

const Tweet = ({ user, content, createdAt }) => {
	return (
		<Card>
			<CardHeader avatar={<Avatar src={user.avatar} />} title={user.displayName} subheader={createdAt} />
			<CardContent>
				<Typography variant="body2" color="text.primary">
					{content}
				</Typography>
			</CardContent>
		</Card>
	);
};

export default Tweet;

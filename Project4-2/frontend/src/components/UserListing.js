import { Avatar, Button, Card, CardContent, CardHeader, Typography } from "@mui/material"
import { getLoggedInUser, isSubscribed, subscribeToUser, unsubscribeUser } from "../data/LocalStorageDB"

const UserListing = ({user}) => {
    return <Card>
        <CardHeader 
            avatar={<Avatar src={user.avatar}/>}
            title={user.displayName}
            subheader={'@' + user.username}/>

        <CardContent sx={{ flex: '1 0 auto' }}>
            {
                user.username === getLoggedInUser().username 
                ? <Button variant="contained" disabled>You</Button>
                : isSubscribed(user.username) 
                ? <Button variant="outlined" onClick={() => unsubscribeUser(user.username)}>Unsubscribe</Button> 
                :
                <Button variant="contained" onClick={() => subscribeToUser(user.username)}>Subscribe</Button>
            }
        </CardContent>
    </Card>
}

export default UserListing
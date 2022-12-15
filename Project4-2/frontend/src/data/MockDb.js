export const USERS = {
    tatiraju: {
        username: 'tatiraju',
        password: 'lmao1234',
        displayName: 'Rishabh Tatiraju',
        userSince: 'December 2022',
        avatar: 'https://randomuser.me/api/portraits/men/38.jpg',
    },
    venkatd: {
        username: 'venkatd',
        password: 'twss1234',
        displayName: 'Venkat Dhavaleswarapu',
        userSince: 'December 2022',
        avatar: 'https://randomuser.me/api/portraits/men/58.jpg',
    },
    rameshram: {
        username: 'rameshram',
        password: 'suresh1234',
        displayName: 'Ramesh Meshram',
        userSince: 'November 2022',
        avatar: 'https://randomuser.me/api/portraits/men/45.jpg',
    }
}


export const TWEETS = [
    {
        user: USERS.rameshram,
        content: 'Looks like I am the first user here. #thefirst',
        createdAt: 'December 1, 2022 3:05 PM',
    },
    {
        user: USERS.venkatd,
        content: 'Almost done with the semester at UF. Time to chill!',
        createdAt: 'December 10, 2022 3:05 PM',
    },
    {
        user: USERS.venkatd,
        content: '@rtatiraju Never realized First Magnitude had live music on weekdays. This is a life altering thing, we should go! #beer',
        createdAt: 'December 13, 2022 3:05 PM',
    },
    {
        user: USERS.venkatd,
        content: 'Used Spotify Car Thing make my car music smart #SmartThings',
        createdAt: 'December 14, 2022 3:05 PM',
    }
]

export const loginAndReturnUser = (username, password) => {
    const user = USERS[username]
    if(user && user.password === password) {
        return user
    } else {
        return null
    }
}

export const loggedIn = false;
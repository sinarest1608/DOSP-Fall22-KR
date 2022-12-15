export const createUser = (user) => {
    let users = localStorage.getItem('users')
    let newUsers = users ? JSON.parse(users) : []
    newUsers.push(user)
    localStorage.setItem('users', JSON.stringify(newUsers))
    return user
}

const getUser = (username) => {
    let users = localStorage.getItem('users')
    let newUsers = users ? JSON.parse(users) : []
    let userMatch = null
    newUsers.forEach(user => {
        if(user.username === username) {
            userMatch = user
        }
    })
    return userMatch
}

export const getAllUsers = () => {
    const users = localStorage.getItem('users')
    return users ? JSON.parse(users) : null
}

export const loginUser = (username, password) => {
    const user = getUser(username)
    if (user && user.password === password) {
        localStorage.setItem('loggedInUser', JSON.stringify(user))
        return user
    }
    return null
}

export const logOutUser = () => {
    localStorage.removeItem('loggedInUser')
    window.location.href = '/'
}

export const isUserLoggedIn = () => {
    return localStorage.getItem('loggedInUser') !== null
}

export const getLoggedInUser = () => {
    return JSON.parse(localStorage.getItem('loggedInUser'))
}

export const addTweet = (tweet) => {
    const date = new Date()
    tweet.createdAt = `${date.getMonth()}-${date.getDate()}-${date.getFullYear()} ${date.getHours()}:${date.getMinutes()}:${date.getSeconds()}`
    let tweets = localStorage.getItem('tweets')
    let newTweets = tweets ? JSON.parse(tweets) : []
    newTweets.push(tweet)
    localStorage.setItem('tweets', JSON.stringify(newTweets))
}

export const subscribeToUser = (userToSubscribe) => {
    const key = getLoggedInUser().username + '_subs'
    let subs = localStorage.getItem(key)
    let newSubs = subs ? JSON.parse(subs) : []
    newSubs.push(userToSubscribe)
    localStorage.setItem(key, JSON.stringify(newSubs))
    window.location.reload()
}

export const getSubscribtionsOfUser = (username) => {
    const key = username + '_subs'
    let subs = localStorage.getItem(key)
    return subs ? JSON.parse(subs) : []
}

export const isSubscribed = (userToCheck) => {
    const key = getLoggedInUser().username + '_subs'
    let subs = localStorage.getItem(key)
    let newSubs = subs ? JSON.parse(subs) : []
    return newSubs.indexOf(userToCheck) !== -1
}

export const unsubscribeUser = (userToUnsubscribe) => {
    const key = getLoggedInUser().username + '_subs'
    let subs = localStorage.getItem(key)
    let newSubs = subs ? JSON.parse(subs) : []
    const index = newSubs.indexOf(userToUnsubscribe)
    if (index > -1) {
        newSubs.splice(index, 1)
    }
    localStorage.setItem(key, JSON.stringify(newSubs))

    window.location.reload()
}

export const getAllTweets = () => {
    const tweets = localStorage.getItem('tweets')
    return tweets ? JSON.parse(tweets) : []
}

export const getTweetsOfSubscribed = (username) => {
    const tweets = localStorage.getItem('tweets')
    const tweetsJson = tweets ? JSON.parse(tweets) : []
    const tweetsToSend = []
    const subs = getSubscribtionsOfUser(username)
    tweetsJson.forEach(tweet => {
        if(subs.indexOf(tweet.user.username) > -1) {
            tweetsToSend.push(tweet)
        }
    });

    return tweetsToSend
}

const getTweetsByHashTag = (hashTag) => {
    const tweets = localStorage.getItem('tweets')
    const tweetsJson = tweets ? JSON.parse(tweets) : []
    const tweetsToSend = []
    tweetsJson.forEach(tweet => {
        if(tweet.content.contains(hashTag)) {
            tweetsToSend.push(tweet)
        }
    });

    return tweetsToSend
}

const getTweetsByMention = (mention) => {
    const tweets = localStorage.getItem('tweets')
    const tweetsJson = tweets ? JSON.parse(tweets) : []
    const tweetsToSend = []
    tweetsJson.forEach(tweet => {
        if(tweet.content.contains(mention)) {
            tweetsToSend.push(tweet)
        }
    });
    
    return tweetsToSend

}
import FeedPage from "./Feed";
import LoginPage from "./Login";
import { getLoggedInUser } from "../data/LocalStorageDB";

const HomePage = () => {
    if  (getLoggedInUser() === null) {
        return <LoginPage />
    } else {
        return <FeedPage />
    }
}

export default HomePage
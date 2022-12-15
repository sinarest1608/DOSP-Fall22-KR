import React from 'react';
import ReactDOM from 'react-dom/client';
import './index.css';
import { Button, Container, TextField, Typography } from '@mui/material';

import { createBrowserRouter, RouterProvider } from 'react-router-dom';
import HomePage from './pages/Home';
import LoginPage from './pages/Login';
import SignUpPage from './pages/SignUp';
import NewTwitPage from './pages/Tweet';
import UserListingPage from './pages/Users';
import SearchPage from './pages/Search';
const router = createBrowserRouter([
	{
		path: '/',
		element: <HomePage />
	},
	{
		path: '/login',
		element: <LoginPage />
	},
	{
		path: '/signup',
		element: (
			<Container
				sx={{ margin: 0 }}
				maxWidth={false}
				style={{ background: '#1DA1F2', height: '100vh', justifyContent: 'center', display: 'flex' }}
			>
				<SignUpPage />
			</Container>
		)
	},
	{
		path: '/tweet',
		element: <NewTwitPage />
	},
	{
		path: '/users',
		element: <UserListingPage />
	},
	{
		path: '/search',
		element: <SearchPage />
	}
]);

const root = ReactDOM.createRoot(document.getElementById('root'));
root.render(
	<React.StrictMode>
		<RouterProvider router={router} />
	</React.StrictMode>
);

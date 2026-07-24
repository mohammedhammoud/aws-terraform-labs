import React from 'react';
import ReactDOM from 'react-dom/client';
import { QueryClient, QueryClientProvider } from '@tanstack/react-query';
import { RouterProvider, createBrowserRouter } from 'react-router-dom';

import { App } from './App';
import { loadConfig } from './config';
import { CreateTodoPage } from './pages/CreateTodoPage';
import { EditTodoPage } from './pages/EditTodoPage';
import { TodoListPage } from './pages/TodoListPage';
import './styles.css';

const queryClient = new QueryClient();

const router = createBrowserRouter([
  {
    path: '/',
    element: <App />,
    children: [
      {
        index: true,
        element: <TodoListPage />,
      },
      {
        path: 'todos/new',
        element: <CreateTodoPage />,
      },
      {
        path: 'todos/:id/edit',
        element: <EditTodoPage />,
      },
    ],
  },
]);

const bootstrap = async () => {
  await loadConfig();

  ReactDOM.createRoot(document.getElementById('root') as HTMLElement).render(
    <React.StrictMode>
      <QueryClientProvider client={queryClient}>
        <RouterProvider router={router} />
      </QueryClientProvider>
    </React.StrictMode>,
  );
};

void bootstrap();

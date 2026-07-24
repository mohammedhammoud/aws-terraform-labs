import { Link, Outlet } from 'react-router-dom';

export const App = () => (
  <div className="app-shell">
    <header className="topbar">
      <Link className="brand" to="/">
        Todo starter
      </Link>
    </header>

    <main className="content">
      <Outlet />
    </main>
  </div>
);

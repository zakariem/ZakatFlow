import React from 'react';
import { Link } from 'react-router-dom';

const Sidebar = () => (
  <aside className="bg-white shadow h-full w-56 fixed top-0 left-0 flex flex-col z-20">
    <div className="h-20 flex items-center justify-center font-bold text-xl border-b">Dashboard</div>
    <nav className="flex-1 flex flex-col gap-2 p-4">
      <Link to="/dashboard/" className="py-2 px-4 rounded hover:bg-gray-100 font-medium">Overview</Link>
      <Link to="/dashboard/paymentManagement" className="py-2 px-4 rounded hover:bg-gray-100 font-medium">Payment Management</Link>
      <Link to="/dashboard/analytics" className="py-2 px-4 rounded hover:bg-gray-100 font-medium">Analytics</Link>
      <Link to="/dashboard/agent-management" className="py-2 px-4 rounded hover:bg-gray-100 font-medium">Agent Management</Link>
    </nav>
  </aside>
);

export default Sidebar;